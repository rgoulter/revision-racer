//
//  GameQuestion.h
//  RacerGame
//
//  Facilitates the link between FlashSetInfo and the GameViewController.
//
//  This assumes MCQ context wherein answers are presented "synchronously"
//  (all at the same time) alongside the questions.
//  -- This isn't necessarily how the questions & answers will work,
//  depending on how the game mechanics will play out.
//
//  Regardless, it feels like it will be easier to keep the coupling all within
//  one file like this.
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashSetInfoAttributes.h"
#import "FlashSetItemAttributes.h"

// Is this at all useful for future refactoring of
// image/sound into GameQn?
// -- Should this be managed by FlashSetInfo? How?

typedef enum {kFlashSetText, kFlashSetImage, kFlashSetSound} FlashSetInputType;

@interface GameQuestion : NSObject

+ (GameQuestion*)generateFromFlashSet:(FlashSetInfoAttributes*)flashSet;

// This constructor is for the Q+A abstraction.
// (as opposed to Q+4A). **DESIGN**
- (id)initFromFlashSetItem:(FlashSetItemAttributes*)item;

@property FlashSetInfoAttributes *flashSet;

// We only support TEXT answers at the moment.
// Best to subclass(?) for Image and Sound?? -- how to access image/sound?

- (NSString*)questionText;

// Answers to be in shuffled order from here; no need to shuffle further.
- (NSArray*)answers;

- (NSString*)correctAnswer;

- (BOOL)isAnswerCorrect:(NSString*)answer;

@end
