//
//  GameResultInfo.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GameResultInfo : NSManagedObject

@property (nonatomic, retain) NSDate * playedDate;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * setId;
@property (nonatomic, retain) NSSet *hasDetails;
@end

@interface GameResultInfo (CoreDataGeneratedAccessors)

- (void)addHasDetailsObject:(NSManagedObject *)value;
- (void)removeHasDetailsObject:(NSManagedObject *)value;
- (void)addHasDetails:(NSSet *)values;
- (void)removeHasDetails:(NSSet *)values;

@end
