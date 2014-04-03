//
//  SpaceShip.h
//  RacerGame
//
//  Created by Richard Goulter on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SpaceShip : NSObject

@property CGPoint pointOnScreen;
@property CGPoint destinationPointOnScreen;

@property (readonly) CGPoint deltaPositionVector; // change in position
@property (readonly) CGFloat speed; // speed on screen

- (id)initInView:(UIView*)v;

// interval in seconds
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;

- (void)respondToPanGesture:(UIPanGestureRecognizer*)recog;
- (void)respondToTapGesture:(UITapGestureRecognizer*)recog;

@end
