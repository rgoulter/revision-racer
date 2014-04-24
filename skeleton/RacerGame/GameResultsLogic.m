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
#import "Constants.h"

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
    GameResultInfo* entity = [NSEntityDescription insertNewObjectForEntityForName:GAME_RESULT_INFO_ENTITY_NAME
                                                                inManagedObjectContext:self.context];
    entity.setId = result.setId;
    entity.playedDate = result.playedDate;
    entity.score = result.score;
    entity.userId = [[UserInfoLogic singleton] getPersistentActiveUser].userId;
    
    for (GameResultDetailsAttributes* currentItem in details) {
        GameResultDetails* persistentDetail = [NSEntityDescription insertNewObjectForEntityForName:GAME_RESULT_DETAILS_ENTITY_NAME
                                                                            inManagedObjectContext:self.context];
        persistentDetail.flashCardId = currentItem.flashCardId;
        persistentDetail.totalGuesses = currentItem.totalGuesses;
        persistentDetail.correctGuesses = currentItem.correctGuesses;
        
        [entity addHasDetailsObject:persistentDetail];
    }
    
    NSError* error = nil;
    [self.context save:&error];
    
    if (error) {
        NSLog(@"Error encountered while saving results : %@", [error localizedDescription]);
    }
}

-(void)deleteDetailsForItemWithId:(NSNumber*)itemId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:GAME_RESULT_DETAILS_ENTITY_NAME
                                              inManagedObjectContext:self.context];
    
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"flashCardId = %@",itemId];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:matchCondition];
    
    NSError* error = nil;
    NSArray* fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!error) {
        [self.context save:&error];
        if ([fetchedObjects count] > 0) {
            GameResultDetails* objectToDelete = [fetchedObjects lastObject];
            [self.context deleteObject:objectToDelete];
        }
    }
}

//Returns nil if no sets have been played or no sets are present
//TODO: Raise exception
-(FlashSetInfoAttributes*)getMostFrequentlyPlayedSet
{
    //Group by id and count of the number of the occurences
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:GAME_RESULT_INFO_ENTITY_NAME
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:GAME_RESULT_INFO_ENTITY_NAME
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
        } else {
            return nil;
        }
    }

    return [[FlashSetLogic singleton] getSetForId:idOfLastPlayedSet];
}

-(NSUInteger)getTotalNumberOfSetsPlayed
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:GAME_RESULT_INFO_ENTITY_NAME
                                              inManagedObjectContext:self.context];
    
    NSString* activeUserId = [[UserInfoLogic singleton]getPersistentActiveUser].userId;
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"userId LIKE %@",activeUserId];
    
    NSPropertyDescription* setIdProperty = [[entity propertiesByName] objectForKey:@"setId"];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:@[setIdProperty]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPredicate:matchCondition];
    fetchRequest.returnsDistinctResults = YES;
    
    NSError* error = nil;
    NSArray* fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!error) {
        NSLog(@"Number of total sets played : %lu",(unsigned long)[fetchedObjects count]);
        return [fetchedObjects count];
    }
    return 0;
}

@end
