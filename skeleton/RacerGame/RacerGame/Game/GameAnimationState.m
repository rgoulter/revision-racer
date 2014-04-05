//
//  GameAnimationState.m
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameAnimationState.h"

@implementation GameAnimationState


// For generic callback-type animation states.
- (id)initWithDuration:(NSTimeInterval)ttl
        andDescription:(NSString*)description
           andCallback:(void (^)())f
{
    self = [super init];
    
    if (self) {
        _timeToLive = ttl;
        _description = description;
        _animationOverCallback = f;
    }
    
    return self;
}

// So that GAState can act as an abstration for Timer activities.
- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    _timeToLive -= timeSinceLastUpdate;
    
    // "End" this state, if we've run out of time.
    if (_timeToLive <= 0) {
        [self endState];
    }
}

- (void)cancel
{
    _animationOverCallback = nil;
}

// If we 'tick', then do we need an isExpired?
- (BOOL)isExpired
{
    return _timeToLive <= 0;
}

// This method is called when the state times out,
// or called to otherwise invoke an ending of the state.
//
// e.g. the game may call this when the user pushes some button.
- (void)endState
{
    if(_animationOverCallback) {
        _animationOverCallback();
    }
    
    // Remomve the callback function,
    // so we don't get into an infinite loop.
    _animationOverCallback = nil;
}

@end
