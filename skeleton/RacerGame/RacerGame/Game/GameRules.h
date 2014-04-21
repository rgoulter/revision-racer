//
//  GameRules.h
//  RacerGame
//
//  Created by Richard Goulter on 5/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRules : NSObject

- (void)decreaseQuestionDuration;
- (void)decreaseQuestionDurationByAmount:(NSTimeInterval)delta;
- (void)increaseQuestionDuration;
- (void)increaseQuestionDurationByAmount:(NSTimeInterval)delta;

@property (readonly) float minimumQuestionDuration;
@property (readonly) float maximumQuestionDuration;
@property (readonly) float questionDuration;

@end
