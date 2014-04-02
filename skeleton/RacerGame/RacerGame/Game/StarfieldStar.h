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

@interface StarfieldStar : NSObject
@property (nonatomic, weak) BOShape *shape;
@property float duration;

- (void)setUp;
- (void)tearDown;
- (void)draw;
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;
- (GLKMatrix4)transformation:(GLKMatrix4)mat;
- (BOOL)isExpired;

- (void)setStartPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
- (void)setEndPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
@end