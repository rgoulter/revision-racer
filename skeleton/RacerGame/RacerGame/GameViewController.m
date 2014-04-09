//
//  GameViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"
#import "Shapes.h"
#import "Resources.h"
#import "StarfieldStar.h"
#import "Asteroid.h"
#import "AppDelegate.h"
#import "SpaceShip.h"
#import "GLProgram.h"
#import "GameRules.h"

#define NUM_QUESTIONS 5

#define SHOW_DEBUG_CURSORS NO
#define SHOW_DEBUG_ASTEROID_LANES NO

// Not sure what the best way to do color constants is;
// SPACEBG is for glClearColor(r, g, b, a);
#define SPACEBG_R 0.0074f
#define SPACEBG_G 0.0031f
#define SPACEBG_B 0.1862f

#define ANS_UICOLOR [UIColor colorWithRed:(float)52/256 green:(float)94/256 blue:(float)242/256 alpha:1]
#define QUESTION_UICOLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1]



# pragma mark - Initialisation

@interface GameViewController ()

// These would be good for QuestionSessionManager
@property id<QuestionUI> questionUI;
@property NSMutableArray *answerUIs; // type: id<AnswerUI>

// and these, too.
//@property QuestionState *currentQuestionState;

// **DESIGN** variable type used here??
@property AnswerState *selectedAnswer;

@property (readonly) AnswerGenerationContext *answerGenerationContext;

@property GameRules *gameRules;

// Game Entities
@property SpaceShip *playerShip;

// Cursors for Debugging & such.
@property UIView *spaceshipPositionCursor;
@property UIView *spaceshipDestinationCursor;
@property UIView *selectedAnswerCursor;

@property GLProgram *program;

@end

@implementation GameViewController {
    NSMutableArray *_stars;
    NSMutableArray *_deadAsteroids; // **HACK**
    NSMutableArray *_laneAsteroids; // **HACK**
    NSArray *_starShapes;
    float _timeTillNextAster;
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
    
    
    
    // Setup Game Entities
    _gameRules = [[GameRules alloc] init];
    
    _playerShip = [[SpaceShip alloc] initInView:self.view];
    [_playerShip setPointOnScreen:[self spaceshipRestPosition]];
    
    
    
    // TODO: Initialisation for QuestionSessionManager & other Question Based things.
    // UI variables
    _questionUI = _questionLabel;
    _answerUIs = [NSMutableArray array];
    
    
    // Create AnswerUIs using UICollectionView.
    for (int i = 0; i < NUM_QUESTIONS; i++) {
        CGRect ansRect = [self getUIAnswerRectForIdx:i];
        UIAnswerButton *uiButton = [[UIAnswerButton alloc] initWithFrame:ansRect];
        
        //[[uiButton titleLabel] setFont:[UIFont fontWithName:@"Helvitica Neue" size:180]];
        uiButton.titleLabel.font = [UIFont systemFontOfSize:60];
        [uiButton addTarget:self action:@selector(answerButtonPressed:) forControlEvents:UIControlEventTouchDown];
        
        [self.answersContainerView addSubview:uiButton];
        [_answerUIs addObject:uiButton];
    }
    
    // Set Colors
    [_questionUI setTextColor:QUESTION_UICOLOR];
    for (id<AnswerUI> ansUI in _answerUIs) {
        [ansUI setTextColor:ANS_UICOLOR];
    }
    
    assert(_answerUIs.count > 0);
    
    // Bootstap Answer states
    // (Not sure the best way to initially set these up).
    AnswerGenerationContext *tmpAnsGenCtx = self.answerGenerationContext;
    
    for (id<AnswerUI> ansUI in _answerUIs) {
        // This relies on AnswerState not needing GameQn to generate next
        // AnswerState.
        AnswerState *ansSt = [[AnswerState alloc] initWithGameQuestion:nil andDuration:_gameRules.questionDuration];
        ansSt.answerUI = ansUI;
        ansSt = [ansSt nextAnswerStateFromContext:tmpAnsGenCtx];
    }
    
    [self ensureAnswersUnique];
    
    // Bootstrap QuestionState.
    QuestionState *qnSt = [[QuestionState alloc] initWithGameQuestion:nil andDuration:_gameRules.questionDuration];
    qnSt.questionUI = _questionUI;
    qnSt.questionManager = self;
    qnSt = [qnSt nextQuestionStateFromContext:[[QuestionGenerationContext alloc]
                                               initWithAnswers:self.currentAnswerStates
                                               andDuration:_gameRules.questionDuration]];
    
    
    
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
    
    
    
    // Setup Gesture Handlers
    
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
    
    
    
    _stars = [[NSMutableArray alloc] init];
    _deadAsteroids = [[NSMutableArray alloc] init];
    _laneAsteroids = [[NSMutableArray alloc] init];
    
    self.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    _starShapes = @[[[BOCube alloc] init], [[BOIcosahedron alloc] init], [[BODodecahedron alloc] init]];
    [self setUpGL];
    
    _timeTillNextAster = 0;
    
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

- (AnswerGenerationContext*)answerGenerationContext
{
    assert(self.flashSet != nil);
    assert(_gameRules != nil);
    
    return [[AnswerGenerationContext alloc]
            initWithFlashSet:self.flashSet
            andDuration:_gameRules.questionDuration];
}

- (void)explodeAsteroid:(Asteroid*)aster
{
    NSArray *debris = [aster debrisPieces];
    [aster tick:INFINITY];
    
    for (Asteroid *debrisAster in debris) {
        [_deadAsteroids addObject:debrisAster];
    }
}

- (void)questionAnswered:(QuestionState*)qnState
{
    // This is called when the question has been 'invoked'
    // (by timeout, or because user selected an answer).
    
    NSLog(@"QUESTION ANSWERED");
    
    // So we need to:
    // Check whether correct or not.
    
    // **MAGIC** Colors
    UIColor *correctColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:1];
    UIColor *wrongColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1];
    
    // This should be abstracted out.
    // Also assumes only GameQuestion type is text.
    NSString *selectedAnswerDefnString = _selectedAnswer.question.questionText;
    NSString *questionDefnString = _questionLabel.associatedQuestionState.question.questionText;
    
    if ([selectedAnswerDefnString isEqualToString:questionDefnString]) {
        [_questionLabel setTextColor:correctColor];
        [[_selectedAnswer answerUI] setTextColor:correctColor];
        
        int i = (int)[_answerUIs indexOfObject:[_selectedAnswer answerUI]];
        // Explode correct asteroid.
        // **DESIGN** We could do this cheaper if we associated UIAnswerButton w/ Asteroid..
        NSLog(@"Explode aster for idx:%d", i);
        if (_laneAsteroids.count >= i) {
            // TODO: We need to do this with THREADS in mind;
            // particularly, creating exploded pieces in a background thread, as well as
            // selecting the correct asteroid.
            // (e.g. Race condition, Asteroids in _stars may have been removed already).
            Asteroid *correctAster = [_laneAsteroids objectAtIndex:i]; // **HACK**, probably correct.
            [self explodeAsteroid:correctAster]; // EXPENSIVE
        }
    } else {
        [_questionLabel setTextColor:wrongColor];
        [[_selectedAnswer answerUI] setTextColor:wrongColor];
        
        // find the correct answer & asteroid.
        for (int i = 0; i < _answerUIs.count; i++) {
            id<AnswerUI> ansUI = [_answerUIs objectAtIndex:i];
            
            if ([[ansUI associatedAnswerState].question.questionText
                 isEqualToString:questionDefnString]) {
                [ansUI setTextColor:correctColor];
            }
        }
        
        // Effect for incorrect answer
        [_playerShip incorrectWobble];
    }
    
    //[self checkQnAnsStateRep];
    
    
    // Transfer asteroids from _laneAsteroids to _deadAsteroids
    for (Asteroid *aster in _laneAsteroids) {
        [aster extendLifeByDuration:2];
        [_deadAsteroids addObject:aster];
    }
    [_laneAsteroids removeAllObjects];
    
    
    // Introduce Delay for the following:
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(updateUIWithNextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}



- (void)updateUIWithNextQuestion
{
    // Update the UI appropriately.
    // If we are "synchronising" all answers, (atm maybe; later, no),
    // Then: set all answer UIs..
    
    NSMutableSet *currentAnswerStates = [NSMutableSet set];
    
    for (id<AnswerUI> ansUI in _answerUIs) {
        AnswerState *ansSt = [ansUI associatedAnswerState];
        
        assert(ansSt != nil);
        
        AnswerGenerationContext *ansGenCtx = self.answerGenerationContext;
        
        do {
            ansSt = [ansSt nextAnswerStateFromContext:ansGenCtx];
        } while ([currentAnswerStates containsObject:ansSt]);
        
        [currentAnswerStates addObject:ansSt];
    }
    
    // If we are "staggering" answers,
    // Then: Change the AnswerUI associated with this Qn *if* we got it correct..
    //       then new Qn ui.
    
    // Now set a new qn.
    QuestionState *nextQnState = [_questionUI associatedQuestionState];
    QuestionGenerationContext *qnGenCtx = [[QuestionGenerationContext alloc]
                                           initWithAnswers:[self currentAnswerStates]
                                           andDuration:_gameRules.questionDuration];
    nextQnState = [nextQnState nextQuestionStateFromContext:qnGenCtx];
    
    
    
    // Set colors
    UIColor *ansColor = ANS_UICOLOR;
    UIColor *qnColor = QUESTION_UICOLOR;
    
    [_questionUI setTextColor:qnColor];
    for (id<AnswerUI> ansUI in _answerUIs) {
        [ansUI setTextColor:ansColor];
    }
    
    
    // add 5x lane asteroids. **HACK**
    assert(_laneAsteroids.count == 0);
    for (int i = 0; i < NUM_QUESTIONS; i++) {
        [self addLaneAsteroid:i];
    }
    
    
    if (!_playerShip.isBeingDragged) {
        [_playerShip setDestinationPointOnScreen:[self spaceshipRestPosition] withSpeedPerSecond:SPACESHIP_LOW_SPEED];
    }
}



- (NSArray*)currentAnswerStates {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id<AnswerUI> ansUI in _answerUIs) {
        [result addObject:[ansUI associatedAnswerState]];
    }
    
    return result;
}



- (void)ensureAnswersUnique {
    // Call this to ensure the AnswerUIs all have different Answers displayed.
    
    assert(self.flashSet != nil);
    
    NSMutableSet *currentAnswerStates = [NSMutableSet set];
    
    for (id<AnswerUI> ansUI in _answerUIs) {
        AnswerState *ansSt = [ansUI associatedAnswerState];
        
        assert(ansSt != nil);
        
        AnswerGenerationContext *ansGenCtx = self.answerGenerationContext;
        
        while ([currentAnswerStates containsObject:ansSt]) {
            ansSt = [ansSt nextAnswerStateFromContext:ansGenCtx];
        }
        
        [currentAnswerStates addObject:ansSt];
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
    _selectedAnswer = selectedAnswerState;

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

- (IBAction)finishGameBtnPressed:(id)sender {
    // Go to results screen.
    [self performSegueWithIdentifier:@"gameToResults" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Setup the transition for set selection to game
    if ([segue.identifier isEqualToString:@"gameToResults"]) {
        //GameViewController *gameVC = (GameViewController*)segue.destinationViewController;
        
        // Set the Selected Set information for the game VC.
        // TODO
        // gameVC.flashSet = ...;
    }
}



# pragma mark - OpenGL & GLKit stuff.



- (void)setupGLShader
{
    _program = [[GLProgram alloc]
                initWithVertexShaderFilename:@"shader"
                      fragmentShaderFilename:@"shader"];
}

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self.effect.colorMaterialEnabled = GL_TRUE;
    
    glEnable(GL_DEPTH_TEST);
    
    [_playerShip setUp];
    
    for (BOShape *shape in _starShapes) {
        [shape setUp];
    }
    
    [self setupGLShader];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for (BOShape *shape in _starShapes) {
        [shape tearDown];
    }
    
    [_playerShip tearDown];
    
    self.effect = nil;
}

- (void)tickSpaceShip
{
    [_playerShip tick:self.timeSinceLastUpdate];
    
    // _playerShip.answerHasBeenGiven is used to ensure that the player keeping a
    // pan-gesture about an answer won't repeatedly keep firing of "answered" events.
    
    if (_playerShip.canAnswer &&
        _playerShip.speed < 10 * self.timeSinceLastUpdate) {
        // Check whether we're close to any answer UIs,
        // Set selected answer if so.
        
        for (UIAnswerButton *uiAnsBtn in _answerUIs) {
            // "close enough" = spaceship point in rect of answer
            
            CGRect ansRect = [self.view convertRect:uiAnsBtn.frame
                                           fromView:uiAnsBtn.superview];
            
            if (CGRectContainsPoint(ansRect, _playerShip.pointOnScreen)) {
                [self selectAnswerUI:uiAnsBtn];
                
                
                // I forget what to do here.
                QuestionState *currentQuestionState = [_questionUI associatedQuestionState];
                [currentQuestionState endState]; // invoke.
                
                
                // Deal with SpaceShip so it doesn't trigger "answers" too frequently.
                // Consider **DESIGN** here, as it feels hackish.
                [_playerShip answeredQuestion];
            }
        }
    }
    
    [self setCursor:_spaceshipPositionCursor toPoint:_playerShip.pointOnScreen];
    [self setCursor:_spaceshipDestinationCursor toPoint:_playerShip.destinationPointOnScreen];
}

- (void)tickGameAnimationStates
{
    [[_questionUI associatedQuestionState] tick:self.timeSinceLastUpdate];
    
    for (AnswerState *ansSt in self.currentAnswerStates) {
        [ansSt tick:self.timeSinceLastUpdate];
    }
}

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width /
                         self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    
    // Tick spaceship
    [self tickSpaceShip];
    
    
    // Tick Qn & Answers, etc.
    [self tickGameAnimationStates];
    
    
    // update stars
    // **CODEDUPL** **HACK** Forgive me..
    for (StarfieldStar *star in _stars) {
        [star tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in _deadAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    for (Asteroid *aster in _laneAsteroids) {
        [aster tick:self.timeSinceLastUpdate];
    }
    
    for (int i = (int)[_stars count] - 1; i >= 0; i--) {
        StarfieldStar *star = [_stars objectAtIndex:i];
        
        if ([star isExpired]) {
            [star tearDown];
            [_stars removeObjectAtIndex:i];
        }
    }
    for (int i = (int)[_laneAsteroids count] - 1; i >= 0; i--) {
        // Because _laneAsteroids' lifetime is the same as question duration,
        //  it's likely that the question is answered before this code is.
        // This is here in case we stagger answers?
        Asteroid *aster = [_laneAsteroids objectAtIndex:i];
        
        if ([aster isExpired]) {
            // Do we remove lane asters here?..
            [_laneAsteroids removeObjectAtIndex:i];
            
            NSLog(@"Lane Aster -> Dead Aster, extend");
            [_deadAsteroids addObject:aster];
        }
    }
    for (int i = (int)[_deadAsteroids count] - 1; i >= 0; i--) {
        Asteroid *aster = [_deadAsteroids objectAtIndex:i];
        
        if ([aster isExpired]) {
            [aster tearDown];
            [_deadAsteroids removeObjectAtIndex:i];
        }
    }
    
    // Create a new asteroid every now and then.
    /*
    // Ignore random asteroids for now.
    _timeTillNextAster -= self.timeSinceLastUpdate;
    if (_timeTillNextAster < 0) {
        _timeTillNextAster = 4 / 3 + (arc4random() % 300) / 300;
        
        //[self addARandomStar];
        [self addARandomLaneAsteroid];
    }
    // */
}

- (void)prepareToDrawWithModelViewMatrix:(GLKMatrix4)mvMat
                     andProjectionMatrix:(GLKMatrix4)projMat
{
    [_program use];
    
    GLKMatrix4 mvProjMatrix = GLKMatrix4Multiply(projMat, mvMat);
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
    
    glUniformMatrix4fv([_program uniformIndex:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvProjMatrix.m);
    glUniformMatrix3fv([_program uniformIndex:UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

- (void)drawSpaceShip
{
    // Draws the SpaceShip object (of _playerShip),
    // using coordinates from self.view.
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    CGRect viewFrame = self.view.frame;
    
    // Move the spaceship "forward" from the screen/camera.
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -5);
    
    
    // Translate the spaceship, corresponding to the point on the screen.
    // Magic #'s: I have no idea why 6 and 5 work? (4:3 ratio?).
    //
    // Since SpaceShip understands its coordinates in terms of TopLeft:(0,0),
    //  BottomRight:(width,height), we need to scale to map the coordinates about.
    
    // Scale to ScreenSize <- WorldSize
    GLfloat sw = 6 / viewFrame.size.width;
    GLfloat sh = 5 / viewFrame.size.height;
    modelMatrix = GLKMatrix4Scale(modelMatrix, sw, -(sh), 1);
    
    // Translate, since worldcoord's origin is in center of screen.
    modelMatrix = GLKMatrix4Translate(modelMatrix, -viewFrame.size.width / 2, -viewFrame.size.height / 2, 0);
    modelMatrix = [_playerShip transformation:modelMatrix];
    
    // Scale to WorldSize <- ScreenSize (inverse of above).
    modelMatrix = GLKMatrix4Scale(modelMatrix, 1 / (sw), -1 / (sh), 1);
    
    
    // Now draw the spaceship, since the modelviewMatrix has the right position.
    // **HACK** Awkward hack, check to make sure SpaceShip is drawn the right way. (-z).
    modelMatrix = GLKMatrix4Scale(modelMatrix, 0.4, 0.4, -0.4); // Scale model down.
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    //[_program use];
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([_program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
    [_playerShip draw];
}

- (void)drawAsteroid:(StarfieldStar*)star
{
    // Draw an asteroid with an outline effect
    // Calculate model view matrix.
    GLKMatrix4 modelMatrix;
    GLfloat scale = 0.25;
    
    // Draw "Shadow"
    glDisable(GL_DEPTH_TEST);
    
    modelMatrix = GLKMatrix4Identity; //GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
    modelMatrix = [star transformation:modelMatrix];
    
    // We can scale the object down by applying the scale matrix here.
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
    
    modelMatrix = GLKMatrix4Scale(modelMatrix, 1.1, 1.1, 1.1);
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([_program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 1);
    [star.shape draw];
    
    
    // Draw "Actual"
    glEnable(GL_DEPTH_TEST);
    
    // We can scale the object down by applying the scale matrix here.
    modelMatrix = GLKMatrix4Identity; //GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
    modelMatrix = [star transformation:modelMatrix];
    modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
    
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                       andProjectionMatrix:self.effect.transform.projectionMatrix];
    glUniform1i([_program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
    [star.shape draw];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(SPACEBG_R, SPACEBG_G, SPACEBG_B, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // TODO: draw stars
    for (Asteroid *aster in _laneAsteroids) {
        [self drawAsteroid:aster];
        
        // Draw Star  Path
        if (SHOW_DEBUG_ASTEROID_LANES) {
            self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
            
            [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                               andProjectionMatrix:self.effect.transform.projectionMatrix];
            glUniform1i([_program uniformIndex:UNIFORM_ISOUTLINE_BOOL], 0);
            [aster.pathCurve draw];
        }
    }
    for (Asteroid *aster in _deadAsteroids) { // **HACK** **CODEDUPL**
        [self drawAsteroid:aster];
    }
    
    // draw spaceship
    [self drawSpaceShip];
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
    UIAnswerButton *uiAnsBtn = [_answerUIs objectAtIndex:idx];
    CGPoint uiPt = [self.view convertPoint:uiAnsBtn.center fromView:uiAnsBtn.superview];
    
    return [self worldPointFromPointOnUI:uiPt];
}

- (void)addLaneAsteroid:(NSUInteger)idx
{
    NSLog(@"Generate lane %d aster", (int)idx);
    Asteroid *asteroid = [[Asteroid alloc] init];
    
    asteroid.shape = [[BOAsteroidShape alloc] init];//[_starShapes objectAtIndex:rndShapeIdx];
    
    // Find destination point, depending on where the corresponding answer UI is.
    CGPoint destWorldPt = [self worldPointForLaneNum:idx];
    float x = destWorldPt.x;
    float y = destWorldPt.y;
    
    float dz = (float)(arc4random() % 100) / 10;
    
    [asteroid setStartPositionX:x Y:y Z:-60 + dz];
    [asteroid setEndPositionX:x Y:y Z:-5];
    
    asteroid.duration = _gameRules.questionDuration;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [asteroid setUp];
    
    [_laneAsteroids addObject:asteroid];
}

- (void)addARandomLaneAsteroid
{
    // Rnd of 5 lanes
    NSUInteger rndIdx = arc4random() % NUM_QUESTIONS;
    [self addLaneAsteroid:rndIdx];
}

- (void)addARandomStar
{
    StarfieldStar *star = [[StarfieldStar alloc] init];
    
    int rndShapeIdx = arc4random() % 3;
    star.shape = [_starShapes objectAtIndex:rndShapeIdx];
    
    // This depends on the coords
    float rndX = (float)(arc4random() % 8) - 4;
    float rndY = (float)(arc4random() % 6) - 3;
    
    rndX = 0;
    rndY = -1;
    
    [star setStartPositionX:0 Y:0 Z:-10];
    [star setStartPositionX:rndX Y:rndY Z:-30];
    [star setEndPositionX:rndX Y:rndY Z:-5];
    
    star.duration = 3;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [star setUp];
    
    [_stars addObject:star];
}

@end
