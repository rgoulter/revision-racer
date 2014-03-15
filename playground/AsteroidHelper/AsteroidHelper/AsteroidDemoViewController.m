//
//  AsteroidDemoViewController.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 13/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "AsteroidDemoViewController.h"

@implementation AsteroidDemoViewController

@synthesize context;
@synthesize effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.context = [[EAGLContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create OpenGL ES 2.0 context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // Default shape is isoc.
    if (!self.shape) {
//        self.shape = [[BOCube alloc] init];
        self.shape = [[BOIcosahedron alloc] init];
        // BOIsocahedron
    }
    
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
    
    [self.shape setUp];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self.shape tearDown];
    
    self.effect = nil;
}

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width /
                         self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -7.0f);
    //modelMatrix = GLKMatrix4Rotate(modelMatrix, rotation, 0.0f, 1.0f, 1.618f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, rotation, 1.0f, 1.0f, 0.7f);
    self.effect.transform.modelviewMatrix = modelMatrix;
    
    rotation += self.timeSinceLastUpdate * 1.0f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.6f, 0.6f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    
    [self.shape draw];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.paused = !self.paused;
}

@end
