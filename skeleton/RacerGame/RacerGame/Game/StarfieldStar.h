//
//  StarfieldStar.h
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Shapes.h"
#import "BOCurve.h"

@interface StarfieldStar : NSObject

@property (nonatomic) BOShape *shape;
@property float duration;
@property (nonatomic, readonly) BOCurve *pathCurve;

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;
@property (readonly) float rotationX;
@property (readonly) float rotationY;

- (id)init;
- (id)initWithoutRotation;


- (void)setUp;
- (void)tearDown;
- (void)draw;
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;
- (GLKMatrix4)transformation:(GLKMatrix4)mat;
- (BOOL)isExpired;

- (void)extendLifeByDuration:(NSTimeInterval)duration;

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;

@end