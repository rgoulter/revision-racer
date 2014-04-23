//
//  GameRules.h
//  RacerGame
//
//  Created by Richard Goulter on 5/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRules : NSObject

- (id)initWithStartingQuestionDuration:(float)duration
                          andTimeLimit:(NSTimeInterval)timeLimit;
- (id)initWithStartingQuestionDuration:(float)duration
                      andNumberOfLives:(int)numLives;
- (id)initWithStartingQuestionDuration:(float)duration
                      andNumberOfLives:(int)numLives
                          andTimeLimit:(NSTimeInterval)timeLimit;

+ (GameRules*)defaultGameRules;
+ (GameRules*)trainingModeGameRules;

- (void)decreaseQuestionDuration;
- (void)decreaseQuestionDurationByAmount:(NSTimeInterval)delta;
- (void)increaseQuestionDuration;
- (void)increaseQuestionDurationByAmount:(NSTimeInterval)delta;

- (void)updateRulesForCorrectAnswer;
- (void)updateRulesForIncorrectAnswer;

- (void)tick:(NSTimeInterval)timeSinceLastUpdate;

@property (readonly) float minimumQuestionDuration;
@property (readonly) float maximumQuestionDuration;
@property (readonly) float questionDuration;

@property (readonly) int score;
@property (readonly) int combo;

@property NSTimeInterval timeRemaining;
@property int numLivesRemaining;

@property BOOL timeLimitEnabled;
@property BOOL livesEnabled;

@property (readonly) BOOL isOutOfLives;
@property (readonly) BOOL isOutOfTime;

@end
