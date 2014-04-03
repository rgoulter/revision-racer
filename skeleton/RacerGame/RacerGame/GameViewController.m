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


# pragma mark - Initialisation

@interface GameViewController ()

// These would be good for QuestionSessionManager
@property id<QuestionUI> questionUI;
@property NSArray *answerUIs; // type: id<AnswerUI>

// and these, too.
//@property QuestionState *currentQuestionState;

// **DESIGN** variable type used here??
@property AnswerState *selectedAnswer;

// Game Entities
@property SpaceShip *playerShip;

// Cursors for Debugging & such.
@property UIView *spaceshipPositionCursor;
@property UIView *spaceshipDestinationCursor;
@property UIView *selectedAnswerCursor;

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
        // need to create a flashset, if we don't have one.
        NSLog(@"GameVC wasn't given a flashSet. generating dummy...");
        
        NSManagedObjectContext* cdCtx = [Resources singleton].managedObjectContext;
        
        self.flashSet = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetInfo"
                                                      inManagedObjectContext:cdCtx];
        
        NSMutableSet *itemsSet = [NSMutableSet set];
        
        NSDictionary *dummyValues = @{@"dmyQuestion1": @"dmyAnswer1",
                                      @"dmyQuestion2": @"dmyAnswer2",
                                      @"dmyQuestion3": @"dmyAnswer3",
                                      @"dmyQuestion4": @"dmyAnswer4",
                                      @"dmyQuestion5": @"dmyAnswer5",
                                      @"dmyQuestion6": @"dmyAnswer6",
                                      @"dmyQuestion7": @"dmyAnswer7",
                                      @"dmyQuestion8": @"dmyAnswer8"};
        for (NSString *key in dummyValues.keyEnumerator.allObjects) {
            
            // Holy hell, Core data.
            
            FlashSetItem* fsItem = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetItem" inManagedObjectContext:cdCtx];
            
            fsItem.id = @-1;
            fsItem.term = key;
            fsItem.definition = [dummyValues objectForKey:key];
            
            [itemsSet addObject:fsItem];
        }
        
        self.flashSet.id = @-1;
        self.flashSet.title = @"Dummy FlashSet";
        self.flashSet.createdDate = [NSDate date];
        self.flashSet.modifiedDate = [NSDate date];
        self.flashSet.hasCards = itemsSet;
        self.flashSet.isVisibleTo = [NSMutableSet set];
    }
    
    
    
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
    for (id<AnswerUI> ansUI in _answerUIs) {
        // This relies on AnswerState not needing GameQn to generate next
        // AnswerState.
        AnswerState *ansSt = [[AnswerState alloc] initWithGameQuestion:nil];
        ansSt.answerUI = ansUI;
        
        ansSt = [ansSt nextAnswerState:self.flashSet];
    }
    
    [self ensureAnswersUnique];
    
    // Bootstrap QuestionState.
    QuestionState *qnSt = [[QuestionState alloc] initWithGameQuestion:nil];
    qnSt.questionUI = _questionUI;
    qnSt.questionManager = self;
    qnSt = [qnSt nextQuestionState:[self currentAnswerStates]];
    
    
    
    
    // Setup Game Entities
    _playerShip = [[SpaceShip alloc] initInView:self.view];
    
    
    
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
    
    // TODO
    
    // Update the UI appropriately.
    // If we are "synchronising" all answers, (atm maybe; later, no),
    // Then: set all answer UIs..
    
    NSMutableSet *currentAnswerStates = [NSMutableSet set];
    
    for (id<AnswerUI> ansUI in _answerUIs) {
        AnswerState *ansSt = [ansUI associatedAnswerState];
        
        assert(ansSt != nil);
        
        do {
            ansSt = [ansSt nextAnswerState:self.flashSet];
        } while ([currentAnswerStates containsObject:ansSt]);
        
        [currentAnswerStates addObject:ansSt];
    }
    
    // If we are "staggering" answers,
    // Then: Change the AnswerUI associated with this Qn *if* we got it correct..
    //       then new Qn ui.
    
    // Now set a new qn.
    QuestionState *nextQnState = [_questionUI associatedQuestionState];
    nextQnState = [nextQnState nextQuestionState:[self currentAnswerStates]];
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
        
        while ([currentAnswerStates containsObject:ansSt]) {
            ansSt = [ansSt nextAnswerState:self.flashSet];
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
    [_playerShip setDestinationPointOnScreen:pt];
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
    
    
    // Eventually, we want to have some "delay" animation between,
    // or sime indication that the answer is correct/incorrect.
    
    // I forget what to do here.
    QuestionState *currentQuestionState = [_questionUI associatedQuestionState];
    [currentQuestionState endState]; // invoke.
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

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    self.effect.colorMaterialEnabled = GL_TRUE;
    
    glEnable(GL_DEPTH_TEST);
    
    for (BOShape *shape in _starShapes) {
        [shape setUp];
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for (BOShape *shape in _starShapes) {
        [shape tearDown];
    }
    
    self.effect = nil;
}

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width /
                         self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    
    
    // Tick spaceship
    
    [_playerShip tick:self.timeSinceLastUpdate];
    
    if (_playerShip.speed < 10) {
        // Check whether we're close to any answer UIs,
        // Set selected answer if so.
        
        for (UIAnswerButton *uiAnsBtn in _answerUIs) {
            // "close enough" = spaceship point in rect of answer
            
            CGRect ansRect = [self.view convertRect:uiAnsBtn.frame
                                           fromView:uiAnsBtn.superview];
            
            if (CGRectContainsPoint(ansRect, _playerShip.pointOnScreen)) {
                [self selectAnswerUI:uiAnsBtn];
            }
        }
    }
    
    [self setCursor:_spaceshipPositionCursor toPoint:_playerShip.pointOnScreen];
    [self setCursor:_spaceshipDestinationCursor toPoint:_playerShip.destinationPointOnScreen];
    
    
    
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
    _timeTillNextAster -= self.timeSinceLastUpdate;
    if (_timeTillNextAster < 0) {
        _timeTillNextAster = 4 / 3 + (arc4random() % 300) / 300;
        
        [self addARandomStar];
    }
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
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Disable pausing for now, since we have other gestures
    // going on.
    //self.paused = !self.paused;
}

- (void)addARandomStar
{
    StarfieldStar *star = [[StarfieldStar alloc] init];
    
    int rndShapeIdx = arc4random() % 3;
    star.shape = [_starShapes objectAtIndex:rndShapeIdx];
    
    // This depends on the coords
    float rndX = (float)(arc4random() % 8) - 4;
    float rndY = (float)(arc4random() % 6) - 3;
    [star setStartPositionX:0 Y:0 Z:-10];
    [star setEndPositionX:rndX Y:rndY Z:0];
    
    star.duration = 3;
    
    
    // setUp??
    // TODO: Not sure how it reacts to IF it's called multiple times.
    [star setUp];
    
    [_stars addObject:star];
}

@end
