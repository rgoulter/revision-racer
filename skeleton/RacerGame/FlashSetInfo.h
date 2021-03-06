//
//  FlashSetInfo.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashSetItem, UserInfo;

@interface FlashSetInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSSet *hasCards;
@property (nonatomic, retain) NSSet *isVisibleTo;
@end

@interface FlashSetInfo (CoreDataGeneratedAccessors)

- (void)addHasCardsObject:(FlashSetItem *)value;
- (void)removeHasCardsObject:(FlashSetItem *)value;
- (void)addHasCards:(NSSet *)values;
- (void)removeHasCards:(NSSet *)values;

- (void)addIsVisibleToObject:(UserInfo *)value;
- (void)removeIsVisibleToObject:(UserInfo *)value;
- (void)addIsVisibleTo:(NSSet *)values;
- (void)removeIsVisibleTo:(NSSet *)values;

@end
