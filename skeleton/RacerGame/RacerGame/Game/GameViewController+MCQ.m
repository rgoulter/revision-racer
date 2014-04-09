//
//  GameViewController+MCQ.m
//  RacerGame
//
//  Created by Richard Goulter on 9/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameViewController+MCQ.h"



@implementation GameViewController (MCQ)

@dynamic questionUI;
@dynamic answerUIs;
@dynamic selectedAnswer;
@dynamic answerGenerationContext;

- (void)setUpMCQ
{
    // Dependencies on GameViewController:
    // self.questionUI is a questionUI. (MCQ prop, assigned by GameVC).
    // self.answerUIs is an NSArray of AnswerUIs.
    //
    
    // UI variables
    assert(self.questionUI != nil);
    self.answerUIs = [NSMutableArray array]; // **DEP** on GameVC
    
    
    // Create AnswerUIs using UICollectionView.
    for (int i = 0; i < NUM_QUESTIONS; i++) {
        CGRect ansRect = [self getUIAnswerRectForIdx:i]; // **DEP** on GameVC
        UIAnswerButton *uiButton = [[UIAnswerButton alloc] initWithFrame:ansRect];
        
        //[[uiButton titleLabel] setFont:[UIFont fontWithName:@"Helvitica Neue" size:180]];
        uiButton.titleLabel.font = [UIFont systemFontOfSize:60];
        [uiButton addTarget:self action:@selector(answerButtonPressed:) forControlEvents:UIControlEventTouchDown];
        
        [self.answersContainerView addSubview:uiButton];
        [self.answerUIs addObject:uiButton];
    }
    
    // Set Colors
    [self.questionUI setTextColor:QUESTION_UICOLOR];
    for (id<AnswerUI> ansUI in self.answerUIs) {
        [ansUI setTextColor:ANS_UICOLOR];
    }
    
    assert(self.answerUIs.count > 0);
    
    // Bootstap Answer states
    // (Not sure the best way to initially set these up).
    AnswerGenerationContext *tmpAnsGenCtx = self.answerGenerationContext;
    
    for (id<AnswerUI> ansUI in self.answerUIs) {
        // This relies on AnswerState not needing GameQn to generate next
        // AnswerState.
        AnswerState *ansSt = [[AnswerState alloc]
                              initWithGameQuestion:nil
                                       andDuration:self.gameRules.questionDuration];
        ansSt.answerUI = ansUI;
        ansSt = [ansSt nextAnswerStateFromContext:tmpAnsGenCtx];
    }
    
    [self ensureAnswersUnique];
    
    // Bootstrap QuestionState.
    QuestionState *qnSt = [[QuestionState alloc]
                           initWithGameQuestion:nil
                                    andDuration:self.gameRules.questionDuration];
    qnSt.questionUI = self.questionUI;
    qnSt.questionManager = self;
    qnSt = [qnSt nextQuestionStateFromContext:[[QuestionGenerationContext alloc]
                                               initWithAnswers:self.currentAnswerStates
                                                   andDuration:self.gameRules.questionDuration]];
}



- (AnswerGenerationContext*)answerGenerationContext
{
    assert(self.flashSet != nil);
    assert(self.gameRules != nil);
    
    return [[AnswerGenerationContext alloc]
            initWithFlashSet:self.flashSet
                 andDuration:self.gameRules.questionDuration];
}



- (void)questionAnswered:(QuestionState*)qnState
{
    // This is called when the question has been 'invoked'
    // (by timeout, or because user selected an answer).
    
    NSLog(@"QUESTION ANSWERED");
    
    // So we need to:
    // Check whether correct or not.
    
    // **MAGIC** Colors
    UIColor *correctColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.1 alpha:1];
    UIColor *wrongColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1];
    
    // This should be abstracted out.
    // Also assumes only GameQuestion type is text.
    NSString *selectedAnswerDefnString = self.selectedAnswer.question.questionText;
    NSString *questionDefnString = self.questionLabel.associatedQuestionState.question.questionText;
    
    if ([selectedAnswerDefnString isEqualToString:questionDefnString]) {
        [self.questionLabel setTextColor:correctColor];
        [[self.selectedAnswer answerUI] setTextColor:correctColor];
        
        
        // **DEP** on GameVC / Game
        [self gameEffectForCorrectAnswer];
    } else {
        [self.questionLabel setTextColor:wrongColor];
        [[self.selectedAnswer answerUI] setTextColor:wrongColor];
        
        // find the correct answer & asteroid.
        for (int i = 0; i < self.answerUIs.count; i++) {
            id<AnswerUI> ansUI = [self.answerUIs objectAtIndex:i];
            
            if ([[ansUI associatedAnswerState].question.questionText
                 isEqualToString:questionDefnString]) {
                [ansUI setTextColor:correctColor];
            }
        }
        
        // **DEP** on GameVC / Game
        [self gameEffectForIncorrectAnswer];
    }
    
    
    
    
    
    // Introduce Delay for the following:
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(updateUIWithNextQuestion)
                                   userInfo:nil
                                    repeats:NO];
}



- (void)updateUIWithNextQuestion
{
    // Update the UI appropriately.
    // If we are "synchronising" all answers, (atm maybe; later, no),
    // Then: set all answer UIs..
    
    NSMutableSet *currentAnswerStates = [NSMutableSet set];
    
    for (id<AnswerUI> ansUI in self.answerUIs) {
        AnswerState *ansSt = [ansUI associatedAnswerState];
        
        assert(ansSt != nil);
        
        AnswerGenerationContext *ansGenCtx = self.answerGenerationContext;
        
        do {
            ansSt = [ansSt nextAnswerStateFromContext:ansGenCtx];
        } while ([currentAnswerStates containsObject:ansSt]);
        
        [currentAnswerStates addObject:ansSt];
    }
    
    // If we are "staggering" answers,
    // Then: Change the AnswerUI associated with this Qn *if* we got it correct..
    //       then new Qn ui.
    
    // Now set a new qn.
    QuestionState *nextQnState = [self.questionUI associatedQuestionState];
    QuestionGenerationContext *qnGenCtx = [[QuestionGenerationContext alloc]
                                           initWithAnswers:[self currentAnswerStates]
                                           andDuration:self.gameRules.questionDuration];
    nextQnState = [nextQnState nextQuestionStateFromContext:qnGenCtx];
    
    
    
    // Set colors
    UIColor *ansColor = ANS_UICOLOR;
    UIColor *qnColor = QUESTION_UICOLOR;
    
    [self.questionUI setTextColor:qnColor];
    for (id<AnswerUI> ansUI in self.answerUIs) {
        [ansUI setTextColor:ansColor];
    }
    
   
    // **DEP** on GameVC / game
    [self gameSetUpNewQuestion];
}



- (NSArray*)currentAnswerStates {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id<AnswerUI> ansUI in self.answerUIs) {
        [result addObject:[ansUI associatedAnswerState]];
    }
    
    return result;
}



- (void)ensureAnswersUnique {
    // Call this to ensure the AnswerUIs all have different Answers displayed.
    
    assert(self.flashSet != nil);
    
    NSMutableSet *currentAnswerStates = [NSMutableSet set];
    
    for (id<AnswerUI> ansUI in self.answerUIs) {
        AnswerState *ansSt = [ansUI associatedAnswerState];
        
        assert(ansSt != nil);
        
        AnswerGenerationContext *ansGenCtx = self.answerGenerationContext;
        
        while ([currentAnswerStates containsObject:ansSt]) {
            ansSt = [ansSt nextAnswerStateFromContext:ansGenCtx];
        }
        
        [currentAnswerStates addObject:ansSt];
    }
}




- (void)tickGameAnimationStates
{
    [[self.questionUI associatedQuestionState] tick:self.timeSinceLastUpdate];
    
    for (AnswerState *ansSt in self.currentAnswerStates) {
        [ansSt tick:self.timeSinceLastUpdate];
    }
}



@end
