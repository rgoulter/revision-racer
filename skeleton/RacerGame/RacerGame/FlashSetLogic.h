//
//  FlashSetLogic.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoAttributes.h"
#import "FlashSetInfoAttributes.h"

@interface FlashSetLogic : NSObject

+(FlashSetLogic*)singleton;

-(NSArray*)downloadAllSetsForUserId:(UserInfoAttributes *)user;

-(FlashSetInfoAttributes*)getSetForId:(NSNumber*)setId;

-(NSSet*)getAllItemsInSet:(NSNumber*)setId;

-(NSArray*)getSetsOfActiveUser;
@end
