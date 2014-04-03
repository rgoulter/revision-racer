//
//  SpaceShip.m
//  RacerGame
//
//  Represents the player's avatar for the game.
//  Will presumably manage the GLKit stuff when we get there.
//  Manages animation / destination stuff.
//
//  **DESIGN** I'm unsure how much of 'SpaceShip' can be here and how
//   much would be better off in GameVC.
//
//  Created by Richard Goulter on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SpaceShip.h"

@interface SpaceShip ()

// The view which this spaceship is the "player avatar" for.
@property UIView *view;

@end

@implementation SpaceShip

- (id)initInView:(UIView *)v
{
    self = [super init];
    
    if (self) {
        _view = v;
        
        _pointOnScreen = CGPointMake(0, 0);
        _destinationPointOnScreen = CGPointMake(0, 0);
        _deltaPositionVector = CGPointMake(0, 0);
    }
    
    return self;
}

- (CGFloat)speed
{
    CGPoint d = self.deltaPositionVector;
    CGFloat dx = d.x, dy = d.y;
    
    return sqrtf(dx*dx + dy*dy);
}

- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    CGFloat speedPerSecond = 2000;
    
    // Aim for "destination"
    CGPoint relDestination = CGPointMake(_destinationPointOnScreen.x - _pointOnScreen.x,
                                         _destinationPointOnScreen.y - _pointOnScreen.y);
    CGFloat destVecLen = sqrtf(relDestination.x * relDestination.x + relDestination.y * relDestination.y);
    
    if (destVecLen <= speedPerSecond * timeSinceLastUpdate) {
        _deltaPositionVector = relDestination;
        _pointOnScreen = _destinationPointOnScreen;
    } else {
        CGFloat k = timeSinceLastUpdate * speedPerSecond / destVecLen;
        _deltaPositionVector = CGPointMake(relDestination.x * k,
                                           relDestination.y * k);
        
        _pointOnScreen = CGPointMake(_pointOnScreen.x + _deltaPositionVector.x,
                                     _pointOnScreen.y + _deltaPositionVector.y);
    }
}

- (void)respondToPanGesture:(UIPanGestureRecognizer*)recog
{
    if (recog.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [recog locationInView:self.view];
        
        // TODO: If pt *starts* close-to current spaceship.. HOW TO VETO??
        NSLog(@"Start pan at %f, %f", pt.x, pt.y);
    }
    
    if (recog.state == UIGestureRecognizerStateChanged) {
        CGPoint pt = [recog locationInView:self.view];
        
        _destinationPointOnScreen = pt;
        //_pointOnScreen = pt;
    }
}

- (void)respondToTapGesture:(UITapGestureRecognizer*)recog
{
    if (recog.state == UIGestureRecognizerStateEnded) {
        CGPoint pt = [recog locationInView:self.view];
        
        _destinationPointOnScreen = pt;
    }
}

@end
