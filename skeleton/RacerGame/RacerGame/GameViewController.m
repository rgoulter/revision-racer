//
//  GameViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"
#import "Shapes.h"
#import "StarfieldStar.h"
#import "AppDelegate.h"



# pragma mark - Initialisation

@implementation GameViewController {
    NSMutableArray *_stars;
    NSArray *_starShapes;
    float _timeTillNextAster;
    
    GameQuestion *_currentQn;
}

@synthesize context;
@synthesize effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.flashSet) {
        // need to create a flashset, if we don't have one.
        NSLog(@"GameVC wasn't given a flashSet. generating dummy...");
        
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext* cdCtx = appDelegate.managedObjectContext;
        
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
    
    // Set current question..
    _currentQn = [GameQuestion generateFromFlashSet:_flashSet];
    [self setQuestionTo:_currentQn];
    
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



# pragma mark - QuestionSide logic

- (void)setQuestionTo:(NSString *)qn withAnswers:(NSArray*)answers
{
    self.questionLabel.text = qn;
    
    [self.answerBtn0 setTitle:[answers objectAtIndex:0] forState:UIControlStateNormal];
    [self.answerBtn1 setTitle:[answers objectAtIndex:1] forState:UIControlStateNormal];
    [self.answerBtn2 setTitle:[answers objectAtIndex:2] forState:UIControlStateNormal];
    [self.answerBtn3 setTitle:[answers objectAtIndex:3] forState:UIControlStateNormal];
    [self.answerBtn4 setTitle:[answers objectAtIndex:4] forState:UIControlStateNormal];
}

- (void)setQuestionTo:(GameQuestion*)qn
{
    [self setQuestionTo:qn.questionText withAnswers:qn.answers];
}

- (IBAction)answerButtonPressed:(UIButton *)sender {
    NSLog(@"Pressed answer: %@", sender.titleLabel.text);
    
    // Next question
    _currentQn = [GameQuestion generateFromFlashSet:_flashSet];
    [self setQuestionTo:_currentQn];
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
    self.paused = !self.paused;
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
