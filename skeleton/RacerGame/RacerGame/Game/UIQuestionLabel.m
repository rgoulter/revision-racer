//
//  UIQuestionLabel.m
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "UIQuestionLabel.h"



@implementation UIQuestionLabel

@synthesize associatedQuestionState;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}



- (void)setGameQuestion:(GameQuestion*)qn
{
    // Here we assume that GameQuestion.answers
    // has the firstAnswer as *the* answer which it represents.
    //
    // (So maybe more analogous to FlashSetItem?).
    
    // Another assumption is that GameQuestion, at the moment,
    // deals only with kFlashSetText (TEXT) answers. (i.e. no image, sound).
    
    NSString *answerLabel = qn.questionText;
    [self setText:answerLabel];
}

@end
