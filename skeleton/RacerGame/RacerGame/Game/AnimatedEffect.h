//
//  AnimatedEffect.h
//  RacerGame
//
//  Created by Richard Goulter on 10/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Shapes.h"
#import "BOCurve.h"

#import "GLProgram.h"

@interface AnimatedEffect : NSObject

@property (readonly) float age;
@property (readonly) float duration;

- (id)initWithDuration:(float)duration;

- (void)tick:(NSTimeInterval)timeSinceLastUpdate;
- (BOOL)isExpired;

- (void)extendLifeByDuration:(NSTimeInterval)duration;

@end



#pragma mark - Transformation effects

@interface TransformationEffect : AnimatedEffect

- (id)initWithDuration:(float)duration;

- (GLKMatrix4)transformation:(GLKMatrix4)mat;

@end

@interface RotationEffect : TransformationEffect

- (id)initWithRandomRotation;
- (id)initWithRotX:(float)rx DRotX:(float)drx RotY:(float)ry DRotY:(float)dry;

@property (readonly) float rotationX;
@property (readonly) float rotationY;

@end

@interface WobbleEffect : TransformationEffect

@end

@interface PathEffect : TransformationEffect

@property (nonatomic, readonly) BOCurve *pathCurve;

@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float z;

- (id)initWithStartX:(GLfloat)sx Y:(GLfloat)sy Z:(GLfloat)sz
                EndX:(GLfloat)tx Y:(GLfloat)ty Z:(GLfloat)tz
            Duration:(float)duration;

- (void)setUp;
- (void)tearDown;

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;

@end



#pragma mark - Transformation effects

@interface ShaderUniformEffect : AnimatedEffect

- (id)initWithDuration:(float)duration;

- (void)applyForProgram:(GLProgram*)prog;

@end

@interface FadeInEffect : ShaderUniformEffect

- (id)initWithDuration:(float)duration;

@end

@interface FadeOutEffect : ShaderUniformEffect

- (id)initWithDuration:(float)duration;

@end

@interface FlashEffect : ShaderUniformEffect

- (id)initWithDuration:(float)duration AndPeriod:(float)period;

@end

@interface SinusoidalEffect : ShaderUniformEffect

// y = A sin(Bx + C) + D;
- (id)initWithAmplitude:(float)A Frequency:(float)B YOffset:(float)D Duration:(float)duration ForUniform:(NSString*)uniname;

@end