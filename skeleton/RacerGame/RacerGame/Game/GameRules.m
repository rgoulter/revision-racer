//
//  GameRules.m
//  RacerGame
//
//  Governs the logic for the "game rules", e.g.
//  question duration and such.
//
//  What this "responds to" will depend on the dependency interations
//  with GameViewController.
//
//  Created by Richard Goulter on 5/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameRules.h"

@interface GameRules ()

@property float questionDuration;

@property int score;
@property int combo;

@end

@implementation GameRules
{
    float _questionDuration;
}



- (id)initWithStartingQuestionDuration:(float)duration
                      andNumberOfLives:(int)numLives
                          andTimeLimit:(NSTimeInterval)timeLimit
{
    self = [super init];
    
    if (self) {
        _questionDuration = duration;
        
        _timeLimitEnabled = YES;
        _livesEnabled = YES;
        
        _numLivesRemaining = numLives;
        _timeRemaining = timeLimit;
    }
    
    return self;
}



- (id)initWithStartingQuestionDuration:(float)duration
                          andTimeLimit:(NSTimeInterval)timeLimit
{
    self = [super init];
    
    if (self) {
        _questionDuration = duration;
        
        _timeLimitEnabled = YES;
        _livesEnabled = NO;
        
        _timeRemaining = timeLimit;
    }
    
    return self;
}



- (id)initWithStartingQuestionDuration:(float)duration
                      andNumberOfLives:(int)numLives
{
    self = [super init];
    
    if (self) {
        _questionDuration = duration;
        
        _timeLimitEnabled = NO;
        _livesEnabled = YES;
        
        _numLivesRemaining = numLives;
    }
    
    return self;
}




+ (GameRules*)defaultGameRules
{
    return [[GameRules alloc] initWithStartingQuestionDuration:6
                                              andNumberOfLives:3
                                                  andTimeLimit:30];
}





- (id)init
{
    self = [super init];
    
    if (self) {
        _questionDuration = 6;
        
        _timeLimitEnabled = YES;
        _livesEnabled = YES;
        
        _numLivesRemaining = 3; // **MAGIC**
        _timeRemaining = 30; // **MAGIC** Very low initially
    }
    
    return self;
}



- (void)tick:(NSTimeInterval)timeSinceLastUpdate
{
    if (_timeLimitEnabled) {
        _timeRemaining -= timeSinceLastUpdate;
    }
}



- (void)decreaseQuestionDuration
{
    // decrease by 20%
    [self decreaseQuestionDurationByAmount:0.2 * self.questionDuration];
}



- (void)decreaseQuestionDurationByAmount:(NSTimeInterval)delta
{
    self.questionDuration = _questionDuration - delta;
}



- (void)increaseQuestionDuration
{
    // increase by 20%
    [self increaseQuestionDurationByAmount:0.2 * self.questionDuration];
}



- (void)increaseQuestionDurationByAmount:(NSTimeInterval)delta
{
    self.questionDuration = _questionDuration + delta;
}



- (float)minimumQuestionDuration
{
    return 3; // **MAGIC**
}



- (float)maximumQuestionDuration
{
    return 20; // **MAGIC**
}



- (void)setQuestionDuration:(float)duration
{
    // Units in Seconds
    float minDuration = self.minimumQuestionDuration;
    float maxDuration = self.maximumQuestionDuration;
    
    _questionDuration = fminf(maxDuration, fmaxf(minDuration, duration));
}



- (float)questionDuration
{
    return _questionDuration; // seconds
}



- (void)updateRulesForCorrectAnswer
{
    // The user answered the question correctly,
    // so we make the game harder for them by decreasing
    // the amount of time for them to answer questions.
    [self decreaseQuestionDuration];
    
    
    // Increase score; more for higher combo.
    _score += _combo > 0 ? 15 : 10;
    _combo += 1;
}



- (void)updateRulesForIncorrectAnswer
{
    // The user answered the question correctly,
    // so we make the game easier for them by increasing
    // the amount of time for them to answer questions.
    [self increaseQuestionDuration];
    
    // Don't increase score; reset combo.
    _combo = 0;
    
    _numLivesRemaining -= 1;
}



- (BOOL)isOutOfLives
{
    return _livesEnabled && _numLivesRemaining < 0;
}



- (BOOL)isOutOfTime
{
    return _timeLimitEnabled && _timeRemaining < 0;
}

@end
