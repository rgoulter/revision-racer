//
//  UIAnswerButton.m
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "UIAnswerButton.h"



@implementation UIAnswerButton

@synthesize associatedAnswerState;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}



- (void)setGameQuestion:(GameQuestion*)qn
{
    // Here we assume that GameQuestion.answers
    // has the firstAnswer as *the* answer which it represents.
    //
    // (So maybe more analogous to FlashSetItem?).
    
    // We also assume that the return value of Answers is an
    // array of strings
    
    // Another assumption is that GameQuestion, at the moment,
    // deals only with kFlashSetText (TEXT) answers. (i.e. no image, sound).
    
    NSString *answerLabel = [qn.answers firstObject];
    NSLog(@"Set AnswerLabel to %@", answerLabel);
    [self setTitle:answerLabel forState:UIControlStateNormal];
}



- (void)setTextColor:(UIColor*)c
{
    [self setTitleColor:c forState:UIControlStateNormal];
}


@end
