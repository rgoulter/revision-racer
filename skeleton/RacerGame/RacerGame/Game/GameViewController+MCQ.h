//
//  GameViewController+MCQ.h
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController.h"

#define NUM_QUESTIONS 5

#define ANS_UICOLOR [UIColor colorWithRed:(float)52/256 green:(float)94/256 blue:(float)242/256 alpha:1]
#define QUESTION_UICOLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1]



@interface GameViewController (MCQ) <QuestionSessionManager>

// These would be good for QuestionSessionManager
@property id<QuestionUI> questionUI;
@property NSMutableArray *answerUIs; // type: id<AnswerUI>

// and these, too.
//@property QuestionState *currentQuestionState;

// **DESIGN** variable type used here??
@property AnswerState *selectedAnswer;

// This gives a linker **WARNING** ?? Look into this.
@property (readonly) AnswerGenerationContext *answerGenerationContext;

@property (readonly) NSMutableDictionary *resultsDetailsTable;


- (void)setUpMCQ;


- (void)tickGameAnimationStates;

@end
