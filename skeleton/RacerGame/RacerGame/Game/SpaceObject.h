//
//  SpaceShape.h
//  RacerGame
//
//  For managing the interaction between GameViewController / GLProgram
//   and a BOShape object, with a bunch of "effects" applied to the shape.
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Shapes.h"
#import "BOCurve.h"

#import "AnimatedEffect.h"



@interface SpaceObject : NSObject

@property (nonatomic) BOShape *shape;

@property (nonatomic, readonly) BOCurve *pathCurve;

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;

@property (readonly) PathEffect *path;

// will separate between effects into transform and uniform.
- (id)initWithShape:(BOShape*)shape Path:(PathEffect*)path andEffects:(NSArray*)effects;

- (void)setUp;
- (void)tearDown;

- (void)tick:(NSTimeInterval)timeSinceLastUpdate;

- (GLKMatrix4)transformation:(GLKMatrix4)mat;
- (void)draw;

@end