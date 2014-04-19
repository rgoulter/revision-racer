//
//  GameResultInfo.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GameResultDetails;

@interface GameResultInfo : NSManagedObject

@property (nonatomic, retain) NSDate * playedDate;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * setId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSSet *hasDetails;
@end

@interface GameResultInfo (CoreDataGeneratedAccessors)

- (void)addHasDetailsObject:(GameResultDetails *)value;
- (void)removeHasDetailsObject:(GameResultDetails *)value;
- (void)addHasDetails:(NSSet *)values;
- (void)removeHasDetails:(NSSet *)values;

@end
