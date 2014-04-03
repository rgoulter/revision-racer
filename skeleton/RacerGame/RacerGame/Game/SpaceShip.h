//
//  SpaceShip.h
//  RacerGame
//
//  Created by Richard Goulter on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Shapes.h"

@interface SpaceShip : NSObject

@property CGPoint pointOnScreen;
@property CGPoint destinationPointOnScreen;

@property (readonly) BOShape *shape;

@property (readonly) CGPoint deltaPositionVector; // change in position
@property (readonly) CGFloat speed; // speed on screen

- (id)initInView:(UIView*)v;

- (void)setUp;
- (void)tearDown;
- (void)draw;
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;
- (GLKMatrix4)transformation:(GLKMatrix4)mat;

- (void)respondToPanGesture:(UIPanGestureRecognizer*)recog;
- (void)respondToTapGesture:(UITapGestureRecognizer*)recog;

@end
