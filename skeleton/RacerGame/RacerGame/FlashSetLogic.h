//
//  FlashSetLogic.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoAttributes.h"

@interface FlashSetLogic : NSObject

-(id)initWithManagedObjectContect:(NSManagedObjectContext*)context;

-(NSArray*)downloadSetsForUserId:(UserInfoAttributes *)user;

@end
