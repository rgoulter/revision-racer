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



// forward-declare.
@protocol AnswerUI;



// QuestionGenerationContext is used to carry information to
// QuestionState for generating from GameViewController,
// so we don't have to change the method signature so often.
// **DESIGN** implications??
@interface AnswerGenerationContext : NSObject

- (id)initWithFlashSet:(FlashSetInfoAttributes*)flashSet andDuration:(float)t;

@property (readonly) FlashSetInfoAttributes *flashSet;

// Duration of the next question.
@property (readonly) float questionDuration;

@end




@interface AnswerState : GameAnimationState

@property (nonatomic, readonly) GameQuestion *question;
@property (weak) id<AnswerUI> answerUI;

- (id)initWithGameQuestion:(GameQuestion*)qn andDuration:(float)t;

// We generate the next question state once this one has expired.
//
// We shall generate an answer-state from some FlashSetInfo,
// at the moment just arbitrarily.
- (AnswerState*)nextAnswerStateFromContext:(AnswerGenerationContext*)genCtx;

@end






@protocol AnswerUI <NSObject>

@property AnswerState *associatedAnswerState;

- (void)setGameQuestion:(GameQuestion*)qn;

- (void)setTextColor:(UIColor*)c;

@end