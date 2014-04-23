//
//  GameViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"
#import "GameViewController+MCQ.h"
#import "GameViewController+Game.h"
#import "Shapes.h"
#import "Resources.h"
#import "AppDelegate.h"

#import "GameResultsViewController.h"
#import "BOStarCluster.h"
#import "GameResultInfoAttributes.h"

#import "UserInfoLogic.h"



# pragma mark - Initialisation

@interface GameViewController () <UIAlertViewDelegate>

@property UIAlertView *gameOverAlertView;
@property UIAlertView *pauseMenuAlertView;

// MCQ Category properties
@property id<QuestionUI> questionUI;
@property NSMutableArray *answerUIs; // type: id<AnswerUI>
@property AnswerState *selectedAnswer;
@property (readonly) AnswerGenerationContext *answerGenerationContext;

@property (readonly) NSMutableDictionary *resultsDetailsTable;

// Game Category properties
@property SpaceShip *playerShip;
@property NSMutableArray *stars;
@property NSMutableArray *deadAsteroids; // **HACK**
@property NSMutableArray *laneAsteroids; // **HACK**

@property float timeSinceLastAsteroid;

// Cursors for Debugging & such.
@property UIView *spaceshipPositionCursor;
@property UIView *spaceshipDestinationCursor;
@property UIView *selectedAnswerCursor;

// **TMP**
@property BOStarCluster *starCluster;

@property GLProgram *program;
@property GLProgram *starShaderProgram;

@end

@implementation GameViewController {
}

@synthesize context;
@synthesize effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.flashSet) {
        // **TODO** This should really be an exception, and/or handled by other VCs also.
        assert(false);
    }
    
    
    _gameOverAlertView = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil] ;
    _gameOverAlertView.tag = 2;
    _gameOverAlertView.alertViewStyle = UIAlertViewStyleDefault;
    
    _pauseMenuAlertView = [[UIAlertView alloc] initWithTitle:@"Game Paused"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"End Game", @"Resume", nil];
    _pauseMenuAlertView.tag = 3;
    _pauseMenuAlertView.alertViewStyle = UIAlertViewStyleDefault;
    
    
    
    // If gameRules weren't passed in, use default
    if (!_gameRules) {
        _gameRules = [GameRules trainingModeGameRules];
    }
    if (!_gameRules.livesEnabled) {
        self.livesVC.view.hidden = YES;
        self.livesVC.view.alpha = 0;
    }
    if (!_gameRules.timeLimitEnabled) {
        self.timeRemainingLabel.hidden = YES;
        self.timeRemainingLabel.alpha = 0;
    }
    if (!_gameRules.scoreEnabled) {
        self.scoreLabel.hidden = YES;
        self.scoreLabel.alpha = 0;
        self.scoreComboLabel.hidden = YES;
        self.scoreComboLabel.alpha = 0;
    }
    
    
    [self setUpGameObjects];
    
    
    
    // Setup MCQ logic
    self.questionUI = _questionLabel;
    _resultsDetailsTable = [NSMutableDictionary dictionary];
    [self setUpMCQ];
    
    
    [self setUpDebugCursors];
    
    
    // Setup Gesture Handlers
    [self setUpGestures];
    
    
    
    
    self.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setUpGL];
    
    _starCluster = [[BOStarCluster alloc] initWithNumPoints:100 inWidth:5 Height:3 Length:10];
    [_starCluster setUp];
    
    //*
    // add 5x lane asteroids. **HACK**
    for (int i = 0; i < NUM_QUESTIONS; i++) {
        [self addLaneAsteroid:i];
    }
    // */
}

- (void)viewDidUnload
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDebugCursors
{
    // Setup cursors
    _spaceshipPositionCursor = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    _spaceshipPositionCursor.layer.cornerRadius = 25;
    _spaceshipPositionCursor.layer.backgroundColor =
        [UIColor colorWithRed:1 green:1 blue:0 alpha:0.8].CGColor;
    [self.view addSubview:_spaceshipPositionCursor];
    _spaceshipPositionCursor.hidden = !SHOW_DEBUG_CURSORS;
    
    _spaceshipDestinationCursor = [[UIView alloc] initWithFrame:CGRectMake(150, 150, 10, 10)];
    _spaceshipDestinationCursor.layer.cornerRadius = 5;
    _spaceshipDestinationCursor.layer.backgroundColor =
        [UIColor colorWithRed:1 green:0 blue:1 alpha:0.5].CGColor;
    [self.view addSubview:_spaceshipDestinationCursor];
    _spaceshipDestinationCursor.hidden = !SHOW_DEBUG_CURSORS;
    
    _selectedAnswerCursor = [[UIView alloc] initWithFrame:CGRectMake(250, 250, 20, 20)];
    _selectedAnswerCursor.layer.cornerRadius = 10;
    _selectedAnswerCursor.layer.backgroundColor =
        [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3].CGColor;
    [self.view addSubview:_selectedAnswerCursor];
    _selectedAnswerCursor.hidden = !SHOW_DEBUG_CURSORS;
}



- (void)setUpGestures
{
    // Presumably playerShip can't be nil by the time we setUpGestures?
    
    // Create and initialize a tap gesture
    UIPanGestureRecognizer *panRecognizer =
        [[UIPanGestureRecognizer alloc]
         initWithTarget:_playerShip action:@selector(respondToPanGesture:)];
    
    // Add the tap gesture recognizer to the view
    [self.view addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:_playerShip action:@selector(respondToTapGesture:)];
    
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];
    
}



# pragma mark - CollectionView Logic

- (uint)numAnswerRows
{
    return 2;
}

- (uint)numAnswerColumnsForRow:(uint)rowIdx
{
    if (rowIdx == 0) {
        return 2;
    } else {
        return 3;
    }
}

- (uint)numAnswers
{
    int sum = 0;
    
    for (int i = 0; i < [self numAnswerRows]; i++) {
        sum += [self numAnswerColumnsForRow:i];
    }
    
    return sum;
}

- (CGSize)answerSizeForRow:(uint)row andCol:(uint)col
{
    // We should calculate this from CollectionView's size.
    CGRect collViewRect = self.answersContainerView.frame;
    
    float w = collViewRect.size.width / 3;
    float h = collViewRect.size.height / 2 / 2; // Half height
    
    return CGSizeMake(w, h);  
}

- (uint)rowForAnswerIndex:(uint)idx
{
    int row = 0;
    
    if (idx < [self numAnswerColumnsForRow:row]) {
        return row;
    } else {
        // Could expand this into a loop, but nah.
        return row + 1;
    }
}

- (uint)colForAnswerIndex:(uint)idx
{
    int row = 0;
    
    if (idx < [self numAnswerColumnsForRow:row]) {
        return idx;
    } else {
        // Could expand this into a loop, but nah.
        idx -= [self numAnswerColumnsForRow:row];
        return idx;
    }
}

- (CGRect)getUIAnswerRectForIdx:(uint)idx
{
    int row = [self rowForAnswerIndex:idx];
    int col = [self colForAnswerIndex:idx];
    
    CGSize size = [self answerSizeForRow:row andCol:col];
    
    int nRows = [self numAnswerRows];
    int nCols = [self numAnswerColumnsForRow:row];
    
    float x = 0;
    float y = 0;
    float xPadding = 0;
    float yPadding = (self.answersContainerView.frame.size.height - nRows * size.height) / (nRows + 1);
    
    if (row == 0) {
        xPadding = (self.answersContainerView.frame.size.width -
                    nCols * size.width) /
                   (nCols + 1);
    }
    
    x = xPadding + (xPadding + size.width) * col;
    y = yPadding + (yPadding + size.height) * row;
    
    return CGRectMake(x, y, size.width, size.height);
}



# pragma mark - QuestionSessionManager logic

- (void)checkQnAnsStateRep
{
    // Because you can never be too sure.
    
    QuestionState *currQnState = [self.questionUI associatedQuestionState];
    
    // Current correct question
    NSString *currQStr = currQnState.question.questionText;
    NSString *currQAns = [currQnState.question.answers objectAtIndex:0];
    
    NSString *currQnUILabelStr = ((UIQuestionLabel*) self.questionUI).text;
    
    assert([currQStr isEqualToString:currQnUILabelStr]);
    
    // Check Answers (AnswerState and AnsUIs).
    assert([self.currentAnswerStates count] == [self.answerUIs count]);
    
    NSMutableSet *ansStatesSet = [NSMutableSet set];
    NSMutableSet *ansUIsSet = [NSMutableSet set];
    
    for (AnswerState *ansSt in self.currentAnswerStates) {
        NSString *ansStr = [ansSt.question.answers objectAtIndex:0];
        [ansStatesSet addObject:ansStr];
    }
    
    for (id<AnswerUI> ansUI in self.answerUIs) {
        NSString *ansStr = ((UIAnswerButton*)ansUI).titleLabel.text;
        [ansUIsSet addObject:ansStr];
    }
    
    assert([ansStatesSet isEqualToSet:ansUIsSet]);
    assert([ansStatesSet containsObject:currQAns]);
}



- (void)explodeAsteroidForSelectedAnswer
{
    int i = (int)[self.answerUIs indexOfObject:[self.selectedAnswer answerUI]];
    
    // Explode correct asteroid.
    // **DESIGN** We could do this cheaper if we associated UIAnswerButton w/ Asteroid..
    if (self.laneAsteroids.count >= i) {
        // TODO: We need to do this with THREADS in mind;
        // particularly, creating exploded pieces in a background thread, as well as
        // selecting the correct asteroid.
        // (e.g. Race condition, Asteroids in _stars may have been removed already).
        Asteroid *correctAster = [self.laneAsteroids objectAtIndex:i]; // **HACK**, probably correct.
        [self explodeAsteroid:correctAster]; // EXPENSIVE
        
        // In order to explode an asteroid,
        // the spaceship must shoot at it.
        [self.playerShip fireLaserAt:correctAster];
    }
}



# pragma mark - QuestionSide logic

- (void)setCursor:(UIView*)cursor toPoint:(CGPoint)pt
{
    CGRect cursorFrame = cursor.frame;
    CGFloat w = cursorFrame.size.width;
    CGFloat r = w / 2;
    
    cursor.frame = CGRectMake(pt.x - r, pt.y - r, w, w);
}

- (void)setSpaceshipDestinationTo:(CGPoint)pt
{
    [_playerShip setDestinationPointOnScreen:pt withSpeedPerSecond:SPACESHIP_HIGH_SPEED];
}

- (CGPoint)spaceshipRestPosition
{
    CGPoint centerPt = self.view.center;
    return CGPointMake(centerPt.x, centerPt.y + 75);
}

- (void)selectAnswerUI:(id<AnswerUI>)answerUI
{
    // Assume the spaceship has its destination here,
    // by its own means.
    
    AnswerState *selectedAnswerState = [answerUI associatedAnswerState];
    self.selectedAnswer = selectedAnswerState;

    // update cursor position to center of Answer Button UI.
    UIAnswerButton *ansBtn = (UIAnswerButton*) answerUI;
    CGPoint pt = [self.view convertPoint:ansBtn.center fromView:ansBtn.superview];
    
    [self setCursor:_selectedAnswerCursor toPoint:pt];
}

- (IBAction)answerButtonPressed:(UIButton *)sender {
    NSLog(@"Pressed answer: %@", sender.titleLabel.text);
    
    // Select the answer associated with this UI.
    // id<AnswerUI> answerUI = (id<AnswerUI>)sender;
    // [self selectAnswerUI:answerUI];
    
    
    // Set destination to the selected question.
    CGPoint pt = [self.view convertPoint:sender.center fromView:sender.superview];
    [self setSpaceshipDestinationTo:pt];
}

- (IBAction)pauseGameBtnPressed:(id)sender {
    [_pauseMenuAlertView show];
    self.paused = YES;
}

- (void)gameOverWithMessage:(NSString*)message
{
    if (!_gameOverAlertView.visible) {
        _gameOverAlertView.message = message;
        [_gameOverAlertView show];
        self.paused = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == _gameOverAlertView.tag) { // GameOver alertview
        [self performSegueWithIdentifier:@"gameToResults" sender:self];
    } else if (alertView.tag == _pauseMenuAlertView.tag) {
        if (buttonIndex == 0) { // Pause Menu alertview
            [self performSegueWithIdentifier:@"gameToResults" sender:self];
        } else if (buttonIndex == 1) { // resume
            self.paused = NO;
        }
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Setup the transition for set selection to game
    if ([segue.identifier isEqualToString:@"gameToResults"]) {
        GameResultsViewController *resultsVC = (GameResultsViewController*)segue.destinationViewController;
        
        GameResultInfoAttributes *gameResultsInfo = [[GameResultInfoAttributes alloc] init];
        gameResultsInfo.playedDate = [NSDate date];
        gameResultsInfo.score = [NSNumber numberWithInt:self.gameRules.score];
        gameResultsInfo.setId = self.flashSet.id;
        gameResultsInfo.userId = [[UserInfoLogic singleton] getActiveUser].userId;
        
        NSArray *results = [self.resultsDetailsTable allValues];
        
        [resultsVC setSummaryOfResults:gameResultsInfo withDetails:results];
    } else if ([segue.identifier isEqualToString:@"GameVCembedsLivesVC"]) {
        _livesVC = (LivesCounterViewController*)segue.destinationViewController;
    }
}



# pragma mark - OpenGL & GLKit stuff.



- (void)setupGLShader
{
    _program = [[MainGLProgram alloc] init];
    _starShaderProgram = [[StarClusterGLProgram alloc] init];
}

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.colorMaterialEnabled = GL_TRUE;
    
    glEnable(GL_DEPTH_TEST);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    [_playerShip setUp];
    
    [self setupGLShader];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [_playerShip tearDown];
    
    self.effect = nil;
}




- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width /
                         self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    // MCQ component
    // Tick Qn & Answers, etc.
    [self tickGameAnimationStates];
    
    
    // Game component
    [self tickGameObjects];
    
    // Cursors
    [self setCursor:_spaceshipPositionCursor toPoint:_playerShip.pointOnScreen];
    [self setCursor:_spaceshipDestinationCursor toPoint:_playerShip.destinationPointOnScreen];
}

- (void)prepareToDrawWithModelViewMatrix:(GLKMatrix4)mvMat
                     andProjectionMatrix:(GLKMatrix4)projMat
{
    [_program use];
    [_program useDefaultUniformValues];
    
    GLKMatrix4 mvProjMatrix = GLKMatrix4Multiply(projMat, mvMat);
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
    
    // **MAGIC**
    glUniformMatrix4fv([_program uniformIndex:@"modelViewProjectionMatrix"], 1, 0, mvProjMatrix.m);
    glUniformMatrix3fv([_program uniformIndex:@"normalMatrix"], 1, 0, normalMatrix.m);
    
    glUniform3f([_program uniformIndex:@"backgroundColor"], SPACEBG_R,  SPACEBG_G,  SPACEBG_B);
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(SPACEBG_R, SPACEBG_G, SPACEBG_B, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawGameObjects];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Disable pausing for now, since we have other gestures
    // going on.
    //self.paused = !self.paused;
}

- (CGPoint)worldPointFromPointOnUI:(CGPoint)uiPt
{
    // uiPt in terms of self.view
    
    // self.center = (0, 0).
    CGPoint uiCenter = self.view.center;
    CGPoint tmpPt = CGPointMake(uiPt.x - uiCenter.x,
                                uiPt.y - uiCenter.y);
    
    // Magic, uiPt(261, 182) - self.center = uiPt (-251, +202) = worldPoint(-1.5, +1)
    
    float xConst = -1.5f / -251;
    float yConst = +1.0f / +202;
    return CGPointMake(tmpPt.x * xConst, -tmpPt.y * yConst);
}

- (CGPoint)worldPointForLaneNum:(NSUInteger)idx
{
    // for Z = -5.
    UIAnswerButton *uiAnsBtn = [self.answerUIs objectAtIndex:idx];
    CGPoint uiPt = [self.view convertPoint:uiAnsBtn.center fromView:uiAnsBtn.superview];
    
    return [self worldPointFromPointOnUI:uiPt];
}



@end
