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
#import "AppDelegate.h"
#import "SpaceShip.h"
#import "GLProgram.h"
#import "GameRules.h"


# pragma mark - Initialisation

@interface GameViewController ()

// These would be good for QuestionSessionManager
@property id<QuestionUI> questionUI;
@property NSArray *answerUIs; // type: id<AnswerUI>

// and these, too.
//@property QuestionState *currentQuestionState;

// **DESIGN** variable type used here??
@property AnswerState *selectedAnswer;

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
    [_playerShip setPointOnScreen:self.view.center];
    
    
    
    // TODO: Initialisation for QuestionSessionManager & other Question Based things.
    // UI variables
    _questionUI = _questionLabel;
    _answerUIs = @[_answerBtn0,
                   _answerBtn1,
                   _answerBtn2,
                   _answerBtn3,
                   _answerBtn4];
    
    // Bootstap Answer states
    // (Not sure the best way to initially set these up).
    AnswerGenerationContext *tmpAnsGenCtx = [[AnswerGenerationContext alloc]
                                             initWithFlashSet:self.flashSet
                                             andDuration:_gameRules.questionDuration];
    
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
    
    _spaceshipDestinationCursor = [[UIView alloc] initWithFrame:CGRectMake(150, 150, 10, 10)];
    _spaceshipDestinationCursor.layer.cornerRadius = 5;
    _spaceshipDestinationCursor.layer.backgroundColor =
        [UIColor colorWithRed:1 green:0 blue:1 alpha:0.5].CGColor;
    [self.view addSubview:_spaceshipDestinationCursor];
    
    _selectedAnswerCursor = [[UIView alloc] initWithFrame:CGRectMake(250, 250, 20, 20)];
    _selectedAnswerCursor.layer.cornerRadius = 10;
    _selectedAnswerCursor.layer.backgroundColor =
        [UIColor colorWithRed:0 green:1 blue:1 alpha:0.3].CGColor;
    [self.view addSubview:_selectedAnswerCursor];
    
    
    
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
    for (int i = 0; i < 5; i++) {
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



# pragma mark - QuestionSessionManager logic

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
    } else {
        [_questionLabel setTextColor:wrongColor];
        [[_selectedAnswer answerUI] setTextColor:wrongColor];
        
        // find the correct answer..
        for (id<AnswerUI> ansUI in _answerUIs) {
            if ([[ansUI associatedAnswerState].question.questionText
                 isEqualToString:questionDefnString]) {
                [ansUI setTextColor:correctColor];
            }
        }
    }
    
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
        
        AnswerGenerationContext *ansGenCtx = [[AnswerGenerationContext alloc]
                                              initWithFlashSet:self.flashSet
                                              andDuration:_gameRules.questionDuration];
        
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
    UIColor *ansColor = [UIColor colorWithRed:(float)52/256 green:(float)94/256 blue:(float)242/256 alpha:1];
    UIColor *qnColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    [_questionUI setTextColor:qnColor];
    for (id<AnswerUI> ansUI in _answerUIs) {
        [ansUI setTextColor:ansColor];
    }
    
    
    //*
    // add 5x lane asteroids. **HACK**
    for (int i = 0; i < 5; i++) {
        [self addLaneAsteroid:i];
    }
    // */
    
    if (!_playerShip.isBeingDragged) {
        [_playerShip setDestinationPointOnScreen:self.view.center withSpeedPerSecond:SPACESHIP_LOW_SPEED];
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
        
        AnswerGenerationContext *ansGenCtx = [[AnswerGenerationContext alloc]
                                              initWithFlashSet:self.flashSet
                                              andDuration:_gameRules.questionDuration];
        
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
    // From: http://iphonedevelopment.blogspot.sg/2010/11/opengl-es-20-for-ios-chapter-4.html
    
    // Shader filenames assumed by GLProgram to be in form of "<name>.vsh" and "<name>.fsh"
    // for vertex and fragment shaders respectively.
    
    _program = [[GLProgram alloc] initWithVertexShaderFilename:@"shader"
                                                     fragmentShaderFilename:@"shader"];
    
    //[program addAttribute:@"position"];
    //[program addAttribute:@"color"];
    
    if (![_program link]) {
        NSLog(@"Link failed");
        NSString *progLog = [_program programLog];
        NSLog(@"Program Log: %@", progLog);
        NSString *fragLog = [_program fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        NSString *vertLog = [_program vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        
        _program = nil;
    }
    
    
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
    
    //[self setupGLShader];
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
                if (!_playerShip.isBeingDragged && NO) {
                    [_playerShip setDestinationPointOnScreen:self.view.center withSpeedPerSecond:SPACESHIP_LOW_SPEED];
                }
            }
        }
    }
    
    [self setCursor:_spaceshipPositionCursor toPoint:_playerShip.pointOnScreen];
    [self setCursor:_spaceshipDestinationCursor toPoint:_playerShip.destinationPointOnScreen];
}

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width /
                         self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    
    // Tick spaceship
    [self tickSpaceShip];
    
    
    // update stars
    for (StarfieldStar *star in _stars) {
        [star tick:self.timeSinceLastUpdate];
    }
    
    for (int i = [_stars count] - 1; i >= 0; i--) {
        StarfieldStar *star = [_stars objectAtIndex:i];
        
        if ([star isExpired]) {
            [star tearDown];
            [_stars removeObjectAtIndex:i];
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
    
    [_program use];
    
    // Now draw the spaceship, since the modelviewMatrix has the right position.
    // **HACK** Awkward hack, check to make sure SpaceShip is drawn the right way. (-z).
    modelMatrix = GLKMatrix4Scale(modelMatrix, 0.4, 0.4, -0.4); // Scale model down.
    self.effect.transform.modelviewMatrix = modelMatrix;
    [self.effect prepareToDraw];
    [_playerShip draw];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.6f, 0.6f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // draw stars
    for (StarfieldStar *star in _stars) {
        // Calculate model view matrix.
        GLKMatrix4 modelMatrix = GLKMatrix4Identity; //GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, scale);
        modelMatrix = [star transformation:modelMatrix];
        
        // We can scale the object down by applying the scale matrix here.
        float scale = 0.25;
        modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
        
        self.effect.transform.modelviewMatrix = modelMatrix;
        [self.effect prepareToDraw];
        [star.shape draw];
        
        self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
        [self.effect prepareToDraw];
        [star.pathCurve draw];
    }
    
    // draw spaceship
    [self drawSpaceShip];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Disable pausing for now, since we have other gestures
    // going on.
    //self.paused = !self.paused;
}

- (void)addLaneAsteroid:(NSUInteger)idx
{
    NSLog(@"Generate lane %d aster", (int)idx);
    StarfieldStar *star = [[StarfieldStar alloc] init];
    
    int rndShapeIdx = arc4random() % 3;
    star.shape = [_starShapes objectAtIndex:rndShapeIdx];
    
    // This depends on the coords
    float xArr[5] = {-1.5, +1.5, -1.75,  0, +1.75};
    float yArr[5] = {  +1,   +1,    -1, -1,    -1};
    float x = xArr[idx];
    float y = yArr[idx];
    
    float dz = 0;//(arc4random() % 100 - 50) / 20;
    
    [star setStartPositionX:x Y:y Z:-30 + dz];
    [star setEndPositionX:x Y:y Z:-5];
    
    star.duration = _gameRules.questionDuration;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [star setUp];
    
    [_stars addObject:star];
}

- (void)addARandomLaneAsteroid
{
    // Rnd of 5 lanes
    NSUInteger rndIdx = arc4random() % 5;
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
