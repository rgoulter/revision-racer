//
//  GameResultsLogic.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameResultInfoAttributes.h"
#import "GameResultDetailsAttributes.h"
#import "FlashSetInfoAttributes.h"

@interface GameResultsLogic : NSObject

+(GameResultsLogic*)singleton;

-(void)saveResults:(GameResultInfoAttributes*)result withDetails:(NSSet*)details;

-(void)deleteDetailsForItemWithId:(NSNumber*)itemId;

-(FlashSetInfoAttributes*)getMostFrequentlyPlayedSet;

-(FlashSetInfoAttributes*)getLastPlayedSet;

-(NSUInteger)getTotalNumberOfSetsPlayed;


@end
