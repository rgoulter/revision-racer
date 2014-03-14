//
//  AsteroidDemoViewController.h
//  AsteroidHelper
//
//  Created by Richard Goulter on 13/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Shapes.h"

@interface AsteroidDemoViewController : GLKViewController
{
    float rotation;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property BOShape *shape;

- (void)setUpGL;
- (void)tearDownGL;

@end
