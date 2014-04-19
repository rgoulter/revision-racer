//
//  GameResultDetailsAttributes.m
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultDetailsAttributes.h"

@implementation GameResultDetailsAttributes

-(id)initWithGameResultDetails:(GameResultDetails *)details
{
    if (self = [super init]) {
        self.correctGuesses = details.correctGuesses;
        self.flashCardId = details.flashCardId;
        self.totalGuesses = details.totalGuesses;
    }
    return self;
}
@end
