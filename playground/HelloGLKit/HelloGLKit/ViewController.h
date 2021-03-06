//
//  ViewController.h
//  HelloGLKit
//
//  Created by Richard Goulter on 11/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController
{
    GLuint vertexBuffer;
    float rotation;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setUpGL;
- (void)tearDownGL;

@end
