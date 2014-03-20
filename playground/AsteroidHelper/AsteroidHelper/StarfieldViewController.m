//
//  StarfieldViewController.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 13/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "StarfieldViewController.h"
#import "Shapes.h"




@interface StarfieldStar : NSObject
@property (nonatomic) BOShape *shape;
@property float duration;

- (void)setUp;
- (void)tearDown;
- (void)draw;
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;
- (GLKMatrix4)transformation:(GLKMatrix4)mat;
- (BOOL)isExpired;
@end

@implementation StarfieldStar {
    float _sx, _sy, _sz;
    float _tx, _ty, _tz;
    float _age;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _age = 0;
    }
    
    return self;
}

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _sx = x;
    _sy = y;
    _sz = z;
}

- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
    _tx = x;
    _ty = y;
    _tz = z;
}

- (void)setUp
{
    [_shape setUp];
}

- (void)tearDown
{
    [_shape tearDown];
}

- (void)draw
{
    // transform?
    // atm, transformation w/ GLKit is handled in the
    // GLKViewController whatever, since that's where the
    // .modelViewMatrix can be accessed. :/
    
    [_shape draw];
}

- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    _age += timeSinceLastUpdate;
}

- (GLKMatrix4)transformation:(GLKMatrix4)mat
{
    // Returns a matrix, M' = translationMat * M
    
    float t = _age / _duration;
    
    if (t > 1) { t = 1; }
    
    // We could rotate here if we wanted to.
    
    // calculate position; P = (1 - t) * A + t * B
    float x = (1 - t) * _sx + t * _tx;
    float y = (1 - t) * _sy + t * _ty;
    float z = (1 - t) * _sz + t * _tz;
    
    return GLKMatrix4Translate(mat, x, y, z);
}

- (BOOL)isExpired
{
    return _age > _duration;
}

@end







@implementation StarfieldViewController {
    NSMutableArray *_stars;
}

@synthesize context;
@synthesize effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _stars = [[NSMutableArray alloc] init];
    
    self.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setUpGL];
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

- (void)setUpGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    // set up stars?
    // (TODO: Not sure if BOShape's setUp behaves when called multiple times).
    for (StarfieldStar *star in _stars) {
        [star setUp];
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // tear down stars
    for (StarfieldStar *star in _stars) {
        [star tearDown];
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
    
    // Ensure we have enough stars.
    while ([_stars count] < 2) {
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
        self.effect.transform.modelviewMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, scale);
        
        [self.effect prepareToDraw];
        [star draw];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.paused = !self.paused;
}

- (void)addARandomStar
{
    StarfieldStar *star = [[StarfieldStar alloc] init];
    
    star.shape = [[BOCube alloc] init];
    
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
