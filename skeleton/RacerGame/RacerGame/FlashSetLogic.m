//
//  FlashSetLogic.m
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "FlashSetLogic.h"
#import "URLHelper.h"
#import "FLashSetInfo.h"
#import "FlashSetInfoAttributes.h"
#import "FlashSetItem.h"
#import "FlashSetItemAttributes.h"
#import "Resources.h"

@interface FlashSetLogic ()

@property(strong,nonatomic)NSManagedObjectContext* context;

@end

@implementation FlashSetLogic

#pragma mark - Getter methods -
-(NSManagedObjectContext *)context
{
    if (!_context) {
        _context = [Resources singleton].managedObjectContext;
    }
    return _context;
}

#pragma mark - Private methods
-(FlashSetInfo*)getPersistentSetForId:(NSNumber*)setId
{
    //TODO: Add assertNotNull code
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FlashSetInfo"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"id = %@",setId];
    [fetchRequest setPredicate:matchCondition];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest
                                                          error:&error];
    //TODO: Assert size of fetchedObjects is 1
    return [fetchedObjects lastObject];
}

#pragma mark - Public methods
-(FlashSetInfoAttributes*)getSetForId:(NSNumber*)setId
{
    FlashSetInfo* persistentObject = [self getPersistentSetForId:setId];
    if (!persistentObject) {
        return [[FlashSetInfoAttributes alloc] initWithFlashSetInfo:persistentObject];
    }
    return nil;
}

-(NSSet *)getAllItemsInSet:(NSNumber*)setId
{
    //Get FlashSetInfo for the setId
    //Using this object, fethc all its "cards"
    //  for each FlashSetItem in "cards"
    //      convert it to its *Attributes object while
    //      adding it to its return set
    
    FlashSetInfo* requiredSet = [self getPersistentSetForId:setId];
    
    //TODO: Can come up with a better strategy
    if (!requiredSet) {
        return nil;
    }
    
    NSSet* persistentCollection = requiredSet.hasCards;
    NSMutableSet* returnSet = [NSMutableSet set];
    
    for (FlashSetItem* currentCard in persistentCollection) {
        FlashSetItemAttributes* attribObject = [[FlashSetItemAttributes alloc] initWithFlashSetItem:currentCard];
        [returnSet addObject:attribObject];
    }
    
    return returnSet;
}

-(NSArray*)downloadSetsForUserId:(UserInfoAttributes *)user
{
    NSURLRequest* request = [URLHelper getCreatedSetsRequestForUser:user.userId AccessToken:user.accessToken];
    NSMutableArray* returnList = [NSMutableArray array];
    
    //TODO: Make async
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                             options:kNilOptions error:nil];
    
    for (NSDictionary* rawSetData in jsonData) {
        //TODO: See if another object exists for the same id
        //If it does and equal to current object, do nothing
        //If it does and uneqaul(use modified), update
        //If it does not exist, create
        
        FlashSetInfo* persistableFlashSet = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetInfo"
                                                                          inManagedObjectContext:self.context];
        persistableFlashSet.id = [rawSetData objectForKey:@"id"];
        persistableFlashSet.title= [rawSetData objectForKey:@"title"];

        NSTimeInterval timeInterval = [[rawSetData objectForKey:@"created_date"] doubleValue];
        persistableFlashSet.createdDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        timeInterval = [[rawSetData objectForKey:@"modified_date"] doubleValue];
        persistableFlashSet.modifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        //Fetch all the terms in the set
        
        NSArray* termsInSet = [rawSetData objectForKey:@"terms"];
        
        for (NSDictionary* eachTermData in termsInSet) {
            FlashSetItem* persistableFlashSetItem = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetItem"
                                                                          inManagedObjectContext:self.context];
            persistableFlashSetItem.id = [eachTermData objectForKey:@"id"];
            persistableFlashSetItem.term = [eachTermData objectForKey:@"term"];
            persistableFlashSetItem.definition = [eachTermData objectForKey:@"definition"];
            
            [persistableFlashSet addHasCardsObject:persistableFlashSetItem];
        }
        
        [returnList addObject:persistableFlashSet];
        NSError *error;
        if (![self.context save:&error]) {
            NSLog(@"For heaven's sake: %@", [error localizedDescription]);
        }
    }
    
    return returnList;
}


@end
