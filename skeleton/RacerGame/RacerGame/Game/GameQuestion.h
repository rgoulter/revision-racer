//
//  GameQuestion.h
//  RacerGame
//
//  Facilitates the link between FlashSetInfo and the GameViewController.
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashSetInfo.h"
#import "FlashSetItem.h"

// Is this at all useful for future refactoring of
// image/sound into GameQn?
// -- Should this be managed by FlashSetInfo? How?

typedef enum {kFlashSetText, kFlashSetImage, kFlashSetSound} FlashSetInputType;

@interface GameQuestion : NSObject

+ (GameQuestion*)generateFromFlashSet:(FlashSetInfo*)flashSet;

@property FlashSetInfo *flashSet;

// We only support TEXT answers at the moment.
// Best to subclass(?) for Image and Sound?? -- how to access image/sound?

- (NSString*)questionText;

// Answers to be in shuffled order from here; no need to shuffle further.
- (NSArray*)answers;

- (NSString*)correctAnswer;

- (BOOL)isAnswerCorrect:(NSString*)answer;

@end
