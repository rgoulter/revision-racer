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
#import "SpaceObject.h"

// **GAMERULE** SpaceShip Speed:
// High Speed for: whenever user taps, drags, clicks button..
// Low Speed for: whenever the game sets the destination. (e.g. back to center).

#define SPACESHIP_HIGH_SPEED 1200
#define SPACESHIP_LOW_SPEED 600

@interface SpaceShip : SpaceObject

// "can answer" = in a state which input is acceptable.
// (e.g. is not moving quickly, has moved since last..).
@property (readonly) BOOL canAnswer;
@property (readonly) BOOL isBeingDragged;

@property CGPoint pointOnScreen;
@property CGPoint destinationPointOnScreen;

@property float speedPerSecond;

@property (readonly) CGPoint deltaPositionVector; // change in position
@property (readonly) CGFloat speed; // speed on screen

- (id)initInView:(UIView*)v;

- (void)setDestinationPointOnScreen:(CGPoint)pt withSpeedPerSecond:(float)sp;

// For setting our 'can answer' flag.
// **DESIGN** is there a better way for SpaceShip to engage w/ GameVC?
// (This is ultimately so we don't fire off at the same answer repeatedly,
//  but GameVC can't access our private check state for this).
- (void)answeredQuestion;

// Start a wobble effect for an incorrect answer
- (void)incorrectWobble;

- (void)respondToPanGesture:(UIPanGestureRecognizer*)recog;
- (void)respondToTapGesture:(UITapGestureRecognizer*)recog;

@end
