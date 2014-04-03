//
//  QuestionState.m
//  RacerGame
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "QuestionState.h"
#import "AnswerState.h"

@implementation QuestionState

- (id)initWithGameQuestion:(GameQuestion*)qn
{
    self = [super initWithDuration:DEFAULT_QUESTION_TIMEOUT
                    andDescription:@""
                       andCallback:^(){
                           // This is called when QuestionState times out,
                           // or the question is answered.
                           
                           // We can pass self to QuestionManager, right?
                           [_questionManager questionAnswered:self];
                       }];
    
    if (self) {
        _question = qn;
    }
    
    return self;
}

// We generate the next question state once this one has expired.
//
// currentAnswerList is expected to be an NSArray of the Answers currently
// on display. (Answers should be of type ... AnswerState?).
//
// (TODO: Do we need to have an abstraction for that list?).
- (QuestionState*)nextQuestionState:(NSArray*)currentAnswerList
{
    // TODO: Implement.
    // Find some answer which has a large TTL, (?), ( = fair chance to answer).
    // and which isn't the same answer as to *this* question. ( = avoid repitition).
    QuestionState *nextQS = nil;
    
    // For now, just pick a random one.
    NSUInteger nextIdx = arc4random() % currentAnswerList.count;
    AnswerState *nextCorrespondingAnswerState = [currentAnswerList objectAtIndex:nextIdx];
    GameQuestion *nextQn = nextCorrespondingAnswerState.question;
    
    nextQS = [[QuestionState alloc] initWithGameQuestion:nextQn];
    nextQS.questionManager = _questionManager;
    
    // Set binding for next question. (Here? Or in the callback?).
    nextQS.questionUI = self.questionUI;
    [nextQS.questionUI setAssociatedQuestionState:nextQS];
    
    // Update the UI itself.
    [nextQS.questionUI setGameQuestion:nextQn];
    
    // self.answerUI maintains a strong reference to self;
    // by reassigning, this means we have no more references to ourselves,
    // so ARC should clean self up.
    
    return nextQS;
}

@end
