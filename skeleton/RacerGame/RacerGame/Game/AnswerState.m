//
//  AnswerState.m
//  RacerGame
//
//  This class is used to facilitate the "animation" of answers for each 'lane'
//   in the game UI.
//
//  AnswerState looks after a given GameQuestion (Q+A pair)
//   binds-with an AnswerUI,
//   and facilitates updating the AnswerUI as the state moves on.
//
//  **DESIGN**: In terms of the binding with AnsUI, it may be that the binding here is too
//   tightly coupled. Hmm.
//
//  Created by Richard Goulter on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "AnswerState.h"
#import "FlashSetLogic.h"



@implementation AnswerGenerationContext

- (id)initWithFlashSet:(FlashSetInfoAttributes *)flashSet andDuration:(float)t
{
    self = [super init];
    
    if (self) {
        _flashSet = flashSet;
        _questionDuration = t;
    }
    
    return self;
}

@end



@interface AnswerState ()

// **HACK** so that when we invoke callback, we can create another AnswerState
@property AnswerGenerationContext *genCtx;

@end

@implementation AnswerState

- (id)initWithGameQuestion:(GameQuestion*)qn andDuration:(float)t
{
    self = [super initWithDuration:t
                    andDescription:@""
                       andCallback:^(){
                           // This is called when AnswerState times out.
                           
                           assert(_genCtx != nil);
                           
                           // Update the AnswerUI in the self.nextAnswerState method.
                           [self nextAnswerStateFromContext:_genCtx];
                       }];
    
    if (self) {
        _question = qn;
    }
    
    return self;
}



- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[AnswerState class]]) {
        // Assumes text-answers only
        
        AnswerState *otherState = (AnswerState*)object;
        NSString *otherAnswer = [otherState.question.answers objectAtIndex:0];
        
        NSString *myAnswer = [_question.answers objectAtIndex:0];

        return [myAnswer isEqualToString:otherAnswer];
    } else {
        return NO;
    }
}



- (NSUInteger)hash
{
    NSString *myAnswer = [_question.answers objectAtIndex:0];
    return [myAnswer hash];
}


// We generate the next question state once this one has expired.
//
// We shall generate an answer-state from some FlashSetInfo,
// at the moment just arbitrarily.
- (AnswerState*)nextAnswerStateFromContext:(AnswerGenerationContext *)genCtx
{
    // Dependencies from Generation context
    FlashSetInfoAttributes *flashSet = genCtx.flashSet;
    float questionDuration = genCtx.questionDuration;
    
    
    assert(flashSet != nil);
    
    // **DESIGN** So, at the moment AnswerState is generating which 'answers'
    // are used from the FlashSetInfo. The problem is that AnswerState doesn't
    // know about the other AnswerStates generating this, and so *uniqueness*
    // of questions could be a concern.
    //
    // * One way around this would be to have, say, QuestionSessionManager
    //   be responsible for generating, since it can see the other answers.
    //
    // * Another would be to change FlashSetInfo argument to some 'delegate' guy
    //   who is responsible for next questions.
    //
    // * The cheap solution at the moment is to just generate random,
    //   and have QuestionSessionManager check for uniqueness. (advancing those
    //   which aren't unique).
    
    AnswerState *nextAS = nil;
    
    
    NSSet *allCards = [[FlashSetLogic singleton] getAllItemsInSet:flashSet.id];
    NSArray *allCardsArray = allCards.allObjects;
    
    // Assertion copypasted from GameQuestion.generate.
    // it's still an important property.
    assert(allCards.count >= 5);
    
    NSUInteger rndIdx = arc4random() % allCardsArray.count;
    FlashSetItemAttributes *chosenFSItem = [allCardsArray objectAtIndex:rndIdx];
    
    // Awkwardly poor GameQuestion constructor.
    // **DESIGN** GameQn
    GameQuestion *gameQn = [[GameQuestion alloc] initFromFlashSetItem:chosenFSItem];
    gameQn.flashSet = flashSet;
    
    
    nextAS = [[AnswerState alloc] initWithGameQuestion:gameQn andDuration:questionDuration];
    
    // Pass the gen context to the answer. (See AnswerState extension).
    nextAS.genCtx = genCtx;
    
    
    // Set binding for next question. (Here? Or in the callback?).
    nextAS.answerUI = self.answerUI;
    [nextAS.answerUI setAssociatedAnswerState:nextAS];
    
    // Update the UI itself
    [nextAS.answerUI setGameQuestion:gameQn];
    
    // self.answerUI maintains a strong reference to self;
    // by reassigning, this means we have no more references to ourselves,
    // so ARC should clean self up.
    
    return nextAS;
}

@end
