//
//  QuestionState.h
//  RacerGame
//
//  This class is used to facilitate the "animation" of questions for each 'lane'
//   in the game UI.
//
//  Qn over: new question is to be generated from a list of answers which are
//            currently displayed and will live for long enough.
//
//  QuestionState has a similar UI binding to like AnswerState.
//
//  QuestionSessionManager comes into things ... I'm not quite sure how at the moment.
//   It manages the "session" of questions used throughout the game.
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameAnimationState.h"
#import "GameQuestion.h"



// forward-declare.
@protocol QuestionUI;
@protocol QuestionSessionManager;



// QuestionGenerationContext is used to carry information to
// QuestionState for generating from GameViewController,
// so we don't have to change the method signature so often.
// **DESIGN** implications??
@interface QuestionGenerationContext : NSObject

- (id)initWithAnswers:(NSArray*)answers andDuration:(float)t;

// AnswersList type is left to some other contractor.
// Currently assumed to be AnswerStates.
@property (readonly) NSArray *answersList;

// Duration of the next question.
@property (readonly) float questionDuration;

@end






@interface QuestionState : GameAnimationState

@property (nonatomic, readonly) GameQuestion *question;
@property (weak) id<QuestionSessionManager> questionManager;
@property (weak) id<QuestionUI> questionUI;

@property (readonly) NSNumber *flashCardId;

- (id)initWithGameQuestion:(GameQuestion*)qn andDuration:(float)t;

// We generate the next question state once this one has expired.
- (QuestionState*)nextQuestionStateFromContext:(QuestionGenerationContext*)genCtx;

@end






@protocol QuestionUI <NSObject>

@property QuestionState *associatedQuestionState;

- (void)setGameQuestion:(GameQuestion*)qn;

- (void)setTextColor:(UIColor*)c;

@end



@protocol QuestionSessionManager <NSObject>

// QuestionMgr will check what the current question has been
- (void)questionAnswered:(QuestionState*)qnState;

// Return array of AnswerState*
- (NSArray*)currentAnswerStates;

// Things I think we'll want (not sure if it's better to
//  declare in protocol, or..?).

@end
