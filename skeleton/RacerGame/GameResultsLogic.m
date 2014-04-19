//
//  GameResultsLogic.m
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultsLogic.h"
#import "FlashSetLogic.h"
#import "Resources.h"
#import "UserInfoLogic.h"

@interface GameResultsLogic()

@property(strong,nonatomic)NSManagedObjectContext* context;

@end

@implementation GameResultsLogic

#pragma mark - Getter methods -
-(NSManagedObjectContext *)context
{
    if (!_context) {
        _context = [Resources singleton].managedObjectContext;
    }
    return _context;
}

#pragma mark - Public methods
+(GameResultsLogic*)singleton
{
    static GameResultsLogic* sharedObj = nil;
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

-(void)saveResults:(GameResultInfoAttributes*)result
       withDetails:(NSSet*)details
{
    //TODO: Add implementation
}

-(void)deleteDetailsForItemWithId:(NSNumber*)itemId
{
    //TODO: Add implementation
}

//Returns nil if no sets have been played or no sets are present
//TODO: Raise exception
-(FlashSetInfoAttributes*)getMostFrequentlyPlayedSet
{
    //Group by id and count of the number of the occurences
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GameResultInfo"
                                              inManagedObjectContext:self.context];
    NSPropertyDescription* setIdAttribute = [entity.propertiesByName objectForKey:@"setId"];
    NSExpression* setIdExpression = [NSExpression expressionForKeyPath:@"setId"];
    NSExpression* countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:setIdExpression]];
    NSExpressionDescription* expressionDescription = [[NSExpressionDescription alloc] init];
    
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    NSString* activeUserId = [[UserInfoLogic singleton]getPersistentActiveUser].userId;
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"userId LIKE %@",activeUserId];
    
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:setIdAttribute, expressionDescription,nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:setIdAttribute]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPredicate:matchCondition];
    
    NSError* error = nil;
    NSArray* fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    NSNumber* idOfMostPlayedSet;
    if (!error) {
        if ([fetchedObjects count] > 0) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
            
            NSArray* sortedArray = [fetchedObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSDictionary* highestCount = [sortedArray firstObject];
            idOfMostPlayedSet = [highestCount objectForKey:@"setId"];
        } else {
            return nil;
        }
    }
    
    //Find the set by id and return to users
    return [[FlashSetLogic singleton] getSetForId:idOfMostPlayedSet];
}

-(FlashSetInfoAttributes*)getLastPlayedSet
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GameResultInfo"
                                              inManagedObjectContext:self.context];
    
    NSString* activeUserId = [[UserInfoLogic singleton]getPersistentActiveUser].userId;
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"userId LIKE %@",activeUserId];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:matchCondition];
    
    NSError* error = nil;
    NSArray* fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    NSNumber* idOfLastPlayedSet;
    if (!error) {
        if ([fetchedObjects count] > 0) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"playedDate" ascending:NO];
            
            NSArray* sortedArray = [fetchedObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            GameResultInfo* latestSet = [sortedArray firstObject];
            idOfLastPlayedSet = latestSet.setId;
            NSLog(@"Id of last played set: %@",idOfLastPlayedSet);
        } else {
            return nil;
        }
    }

    return [[FlashSetLogic singleton] getSetForId:idOfLastPlayedSet];
}

-(NSUInteger)getTotalNumberOfSetsPlayed
{
    return 0;
}

@end
