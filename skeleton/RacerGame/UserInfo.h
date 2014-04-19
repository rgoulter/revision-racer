//
//  UserInfo.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashSetInfo;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSDate * expiryTimestamp;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSSet *canSee;
@end

@interface UserInfo (CoreDataGeneratedAccessors)

- (void)addCanSeeObject:(FlashSetInfo *)value;
- (void)removeCanSeeObject:(FlashSetInfo *)value;
- (void)addCanSee:(NSSet *)values;
- (void)removeCanSee:(NSSet *)values;

@end
