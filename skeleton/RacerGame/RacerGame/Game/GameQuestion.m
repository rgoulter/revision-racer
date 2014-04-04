//
//  GameQuestion.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameQuestion.h"
#import "FlashSetLogic.h"

@interface GameQuestion ()

@property NSArray *flashCards;
@property NSUInteger correctIdx;

@end

@implementation GameQuestion

+ (GameQuestion*)generateFromFlashSet:(FlashSetInfoAttributes*)flashSet
{
    NSSet *allCards = [[FlashSetLogic singleton] getAllItemsInSet:flashSet.id];;
    NSArray *allCardsArray = allCards.allObjects;
    
    assert(allCards.count >= 5);
    
    NSMutableSet *chosenCards = [NSMutableSet set];
    
    // For this to be not super slow,
    // better if |allCardsArray| >> 5
    // (But could do a "without replacement" method of selection, also).
    
    while (chosenCards.count < 5) {
        NSUInteger rndIdx = arc4random() % allCardsArray.count;
        
        FlashSetItem *it = [allCardsArray objectAtIndex:rndIdx];
        [chosenCards addObject:it];
    }
    
    NSMutableArray *cardsArray = [NSMutableArray arrayWithArray:chosenCards.allObjects];
    
    // shuffle.
    
    
    // chose arbitrary qn.
    NSUInteger answerIdx = arc4random() % cardsArray.count;
    
    GameQuestion *gameQn = [[GameQuestion alloc] init];
    gameQn.flashSet = flashSet;
    gameQn.correctIdx = answerIdx;
    gameQn.flashCards = cardsArray;
    
    return gameQn;
}

- (id)initFromFlashSetItem:(FlashSetItemAttributes*)item
{
    self = [super init];
    
    if (self) {
        // This is slightly awkward, as the initial design was that this
        // would be Q+5xA, but now this is used as Q+A.
        
        _correctIdx = 0;
        _flashCards = @[item];
    }
    
    return self;
}

// We only support TEXT answers at the moment.
// Best to subclass(?) for Image and Sound?? -- how to access image/sound?

- (NSString*)questionText
{
    FlashSetItemAttributes *item = [_flashCards objectAtIndex:_correctIdx];
    
    return item.term;
}

// Answers to be in shuffled order from here; no need to shuffle further.
- (NSArray*)answers
{
    NSMutableArray *val = [NSMutableArray array];
    
    for (FlashSetItemAttributes *it in _flashCards) {
        [val addObject:it.definition];
    }
    
    return [NSArray arrayWithArray:val];
}

- (NSString*)correctAnswer
{
    FlashSetItemAttributes *item = [_flashCards objectAtIndex:_correctIdx];
    
    return item.definition;
}

- (BOOL)isAnswerCorrect:(NSString*)answer
{
    // There are several assumptions made here.
    return [self.correctAnswer isEqualToString:answer];
}

@end
