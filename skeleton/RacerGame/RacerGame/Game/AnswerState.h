//
//  AnswerState.h
//  RacerGame
//
//  This class is used to facilitate the "animation" of answers for each 'lane'
//   in the game UI.
//
//  Ans over: New Ans from set suchthat we prob'ly want to test that question.
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameAnimationState.h"
#import "GameQuestion.h"
#import "FlashSetInfoAttributes.h"

// I wish there was a more intermediate representation of
// FlashSets than the Core Data one..
#import "FlashSetInfo.h"

// Time to answer Qns is 10seconds
// **CODEDUPL**
#define DEFAULT_QUESTION_TIMEOUT 10



// forward-declare.
@protocol AnswerUI;



@interface AnswerState : GameAnimationState

@property (nonatomic, readonly) GameQuestion *question;
@property (weak) id<AnswerUI> answerUI;

- (id)initWithGameQuestion:(GameQuestion*)qn;

// We generate the next question state once this one has expired.
//
// We shall generate an answer-state from some FlashSetInfo,
// at the moment just arbitrarily.
- (AnswerState*)nextAnswerState:(FlashSetInfoAttributes*)flashSet;

@end






@protocol AnswerUI <NSObject>

@property AnswerState *associatedAnswerState;

- (void)setGameQuestion:(GameQuestion*)qn;

- (void)setTextColor:(UIColor*)c;

@end