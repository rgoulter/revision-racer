//
//  GameAnimationState.h
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameAnimationState : NSObject

@property (nonatomic, readonly) NSTimeInterval timeToLive; // Unit: seconds.
@property (nonatomic, readonly) NSString *qnDescription;
@property (nonatomic, readonly) void (^animationOverCallback)();

// For generic callback-type animation states.
- (id)initWithDuration:(NSTimeInterval)ttl
        andDescription:(NSString*)description
           andCallback:(void (^)())f;

// So that GAState can act as an abstration for Timer activities.
- (void)tick:(NSTimeInterval)timeSinceLastUpdate;

- (void)cancel;

// If we 'tick', then do we need an isExpired?
- (BOOL)isExpired;

// This method is called when the state times out,
// or called to otherwise invoke an ending of the state.
//
// e.g. the game may call this when the user pushes some button.
- (void)endState;

@end
