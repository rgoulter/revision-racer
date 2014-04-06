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



// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_ISOUTLINE_BOOL,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};



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

//@property GLProgram *program;

@end

@implementation GameViewController {
    NSMutableArray *_stars;
    NSArray *_starShapes;
    float _timeTillNextAster;
    
    GLuint _program;
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
    _answerUIs = [NSMutableArray array];
    
    // Create AnswerUIs using UICollectionView.
    self.answersCollectionView.backgroundColor = [UIColor clearColor];
    self.answersCollectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    // [self.answersCollectionView reloadData]; // UICollectionView is BUGGY, so we need the below, not this.
    [self.answersCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0],
                                                          [NSIndexPath indexPathForItem:1 inSection:0],
                                                          [NSIndexPath indexPathForItem:0 inSection:1],
                                                          [NSIndexPath indexPathForItem:1 inSection:1],
                                                          [NSIndexPath indexPathForItem:2 inSection:1]]];
    
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



- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * newCell = [self.answersCollectionView
                                      dequeueReusableCellWithReuseIdentifier:@"collViewAnswerCell"
                                      forIndexPath:indexPath];
    
    // Take care of the answers label
    
    // This seems a bit **HACK** ish, but
    UIView *v = newCell.subviews.firstObject;
    UIAnswerButton *ansButton = (UIAnswerButton*) v.subviews.firstObject;
    
    assert([ansButton conformsToProtocol:@protocol(AnswerUI)] && ansButton != nil);
    
    [ansButton addTarget:self action:@selector(answerButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [_answerUIs addObject:ansButton];
    
    return newCell;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // NUM ROWS
    return 2;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NUM COLS
    if (section % 2 == 0) {
        return 2;
    } else {
        return 3;
    }
}



// UICollectiovViewDelegateFlowLayout stuff.

- (CGSize)collViewCellSize
{
    // We should calculate this from CollectionView's size.
    CGRect collViewRect = self.answersCollectionView.frame;
    
    float w = self.answersCollectionView.frame.size.width / 3; //collViewRect.size.width / 5;
    float h = collViewRect.size.height / 2; // Assuming answers all together.
    
    return CGSizeMake(w, h);   
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self collViewCellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    // To be fancy??
    if (section == 0) {
        float width = self.answersCollectionView.frame.size.width;
        int n = [self collectionView:collectionView numberOfItemsInSection:section]; // 2;
        float margin = (width - n * [self collViewCellSize].width) / (n - 1 + 2);
        return UIEdgeInsetsMake(0, margin, 0, margin);
    } else {
        // top, left, bottom, right
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}



# pragma mark - QuestionSessionManager logic

- (void)checkQnAnsStateRep
{
    // Because you can never be too sure.
    
    QuestionState *currQnState = [_questionUI associatedQuestionState];
    
    NSLog(@"CHECK REP:");
    NSString *currQStr = currQnState.question.questionText;
    NSString *currQAns = [currQnState.question.answers objectAtIndex:0];
    NSLog(@"Current Qn: %@ = %@", currQStr, currQAns);
    NSLog(@"Qn UI lbl: %@", ((UIQuestionLabel*)_questionUI).text);
    
    for (AnswerState *ansSt in self.currentAnswerStates) {
        NSString *ansStr = [ansSt.question.answers objectAtIndex:0];
        NSLog(@"Answer: %@", ansStr);
    }
    
    NSLog(@"and Ans UIs");
    for (id<AnswerUI> ansUI in _answerUIs) {
        NSLog(@"Ans UI: %@", ((UIAnswerButton*)ansUI).titleLabel.text);
    }
}

- (AnswerGenerationContext*)answerGenerationContext
{
    assert(self.flashSet != nil);
    assert(_gameRules != nil);
    
    return [[AnswerGenerationContext alloc]
            initWithFlashSet:self.flashSet
            andDuration:_gameRules.questionDuration];
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
    
    [self checkQnAnsStateRep];
    
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
    UIColor *ansColor = [UIColor colorWithRed:(float)52/256 green:(float)94/256 blue:(float)242/256 alpha:1];
    UIColor *qnColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    [_questionUI setTextColor:qnColor];
    for (id<AnswerUI> ansUI in _answerUIs) {
        [ansUI setTextColor:ansColor];
    }
    
    
    // ASTEROID OUTRO EFFECT
    /* This is TOO ungracious...
    // At the moment, the visual effect is weird, since this involves just removing the asteroid.
    for (StarfieldStar *star in _stars) {
        [star tick:INFINITY];
    }
    // */
    /*
    // n.b. this probably fails due to unsafe threading.
    while (_stars > 0) {
        StarfieldStar *aster = _stars.lastObject;
        [_stars removeLastObject];
        [aster tearDown];
    }
    // */
    
    
    //*
    // add 5x lane asteroids. **HACK**
    for (int i = 0; i < NUM_QUESTIONS; i++) {
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

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribColor, "color");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_ISOUTLINE_BOOL] = glGetUniformLocation(_program, "isOutline");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)setupGLShader
{
    [self loadShaders];
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

- (void)prepareToDrawWithModelViewMatrix:(GLKMatrix4)mvMat
                     andProjectionMatrix:(GLKMatrix4)projMat
{
    glUseProgram(_program);
    
    GLKMatrix4 mvProjMatrix = GLKMatrix4Multiply(projMat, mvMat);
    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvMat), NULL);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvProjMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
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
    glUniform1i(uniforms[UNIFORM_ISOUTLINE_BOOL], 0);
    [_playerShip draw];
}

- (void)drawAsteroid:(Asteroid*)aster
{
    // Draw an asteroid with an outline effect
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.6f, 0.6f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // draw stars
    for (StarfieldStar *star in _stars) {
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
        glUniform1i(uniforms[UNIFORM_ISOUTLINE_BOOL], 1);
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
        glUniform1i(uniforms[UNIFORM_ISOUTLINE_BOOL], 0);
        [star.shape draw];
        
        
        
        // Draw Star  Path
        self.effect.transform.modelviewMatrix = GLKMatrix4Identity;
        
        [self prepareToDrawWithModelViewMatrix:self.effect.transform.modelviewMatrix
                           andProjectionMatrix:self.effect.transform.projectionMatrix];
        glUniform1i(uniforms[UNIFORM_ISOUTLINE_BOOL], 0);
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
    Asteroid *asteroid = [[Asteroid alloc] init];
    
    int rndShapeIdx = arc4random() % 3;
    asteroid.shape = [[BOAsteroidShape alloc] init];//[_starShapes objectAtIndex:rndShapeIdx];
    
    // This depends on the coords
    float xArr[5] = {-1.5, +1.5, -1.75,  0, +1.75};
    float yArr[5] = {  +1,   +1,    -1, -1,    -1};
    float x = xArr[idx];
    float y = yArr[idx];
    
    float dz = 0;//(arc4random() % 100 - 50) / 20;
    
    [asteroid setStartPositionX:x Y:y Z:-30 + dz];
    [asteroid setEndPositionX:x Y:y Z:-5];
    
    asteroid.duration = _gameRules.questionDuration;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [asteroid setUp];
    
    [_stars addObject:asteroid];
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
