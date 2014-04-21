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

@end

@implementation GameRules
{
    float _questionDuration;
}



- (id)init
{
    self = [super init];
    
    if (self) {
        _questionDuration = 6;
    }
    
    return self;
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

@end
