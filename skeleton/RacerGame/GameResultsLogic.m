//
//  GameResultsLogic.m
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultsLogic.h"
#import "Resources.h"

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
    NSAttributeDescription* setIdAttribute = [entity.propertiesByName objectForKey:@"setId"];
    NSExpression* setIdExpression = [NSExpression expressionForKeyPath:@"setId"];
    NSExpression* countExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:setIdExpression]];
    NSExpressionDescription* expressionDescription = [[NSExpressionDescription alloc] init];
    
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
    
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:setIdAttribute, countExpression, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObject:setIdAttribute]];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSError* error = nil;
    NSArray* fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!error) {
        NSLog(@"Does this execute");
    }
    
    //Find the set by id and return to users
    return nil;
}

-(FlashSetInfoAttributes*)getLastPlayedSet
{
    //TODO: Add implementation
    return nil;
}

-(NSUInteger)getTotalNumberOfSetsPlayed
{
    //TODO: Add implementation
    return 0;
}

@end
