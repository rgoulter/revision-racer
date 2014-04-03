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

// Time to answer Qns is 10seconds
#define DEFAULT_QUESTION_TIMEOUT 10



// forward-declare.
@protocol QuestionUI;
@protocol QuestionSessionManager;






@interface QuestionState : GameAnimationState

@property (nonatomic, readonly) GameQuestion *question;
@property (weak) id<QuestionSessionManager> questionManager;
@property (weak) id<QuestionUI> questionUI;

- (id)initWithGameQuestion:(GameQuestion*)qn;

// We generate the next question state once this one has expired.
//
// currentAnswerList is expected to be an NSArray of the Answers currently
// on display.
// (TODO: Do we need to have an abstraction for that?).
- (QuestionState*)nextQuestionState:(NSArray*)currentAnswerList;

@end






@protocol QuestionUI <NSObject>

@property QuestionState *associatedQuestionState;

- (void)setGameQuestion:(GameQuestion*)qn;

@end



@protocol QuestionSessionManager <NSObject>

// QuestionMgr will check what the current question has been
- (void)questionAnswered:(QuestionState*)qnState;

// Return array of AnswerState*
- (NSArray*)currentAnswerStates;

// Things I think we'll want (not sure if it's better to
//  declare in protocol, or..?).

@end
