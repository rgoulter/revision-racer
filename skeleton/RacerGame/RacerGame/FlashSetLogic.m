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
    if (!error) {
        if ([fetchedObjects count] > 0) {
            return [fetchedObjects lastObject];
        }
    }
    return nil;
}

-(FlashSetItem*)getPersistentSetItemForId:(NSNumber*)setItemId
{
    //TODO: Add assertNotNull code
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FlashSetItem"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"id = %@",setItemId];
    [fetchRequest setPredicate:matchCondition];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest
                                                          error:&error];
    //TODO: Assert size of fetchedObjects is 1
    if (!error) {
        if ([fetchedObjects count] > 0) {
            return [fetchedObjects lastObject];
        }
    }
    return nil;
}

-(void)updateFlashSet:(FlashSetInfoAttributes*)flashSet withItems:(NSSet*)setOfCards
{
    FlashSetInfo* persistentFlashSet = [self getPersistentSetForId:flashSet.id];
    
    if(persistentFlashSet) {
        persistentFlashSet.modifiedDate = flashSet.modifiedDate;
        persistentFlashSet.createdDate = flashSet.createdDate;
        persistentFlashSet.title = flashSet.title;
    } else {
        persistentFlashSet = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetInfo"
                                                            inManagedObjectContext:self.context];
        persistentFlashSet.id = flashSet.id;
        persistentFlashSet.modifiedDate = flashSet.modifiedDate;
        persistentFlashSet.createdDate = flashSet.createdDate;
        persistentFlashSet.title = flashSet.title;
    }
    
    for (FlashSetItemAttributes* eachCard in setOfCards) {
        FlashSetItem* persistableFlashSetItem = [self getPersistentSetItemForId:eachCard.id];
        
        if (!persistableFlashSetItem) {
            persistableFlashSetItem = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetItem"
                                                                    inManagedObjectContext:self.context];
            persistableFlashSetItem.id = eachCard.id;
        }
        persistableFlashSetItem.term = eachCard.term;
        persistableFlashSetItem.definition = eachCard.definition;
        [persistentFlashSet addHasCardsObject:persistableFlashSetItem];
    }
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Problem while persisting Flash set and items: %@", [error localizedDescription]);
    }
}

-(NSSet*)downloadSetsForRequest:(NSURLRequest*)request
{
    NSMutableSet* returnSet = [NSMutableSet set];
    
    //TODO: Make async
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                        options:kNilOptions
                                                          error:nil];
    
    for (NSDictionary* rawSetData in jsonData) {
        //TODO: See if another object exists for the same id
        //If it does and equal to current object, do nothing
        //If it does and unequal(use modified), update
        //If it does not exist, create
        
        FlashSetInfoAttributes* flashSet = [[FlashSetInfoAttributes alloc] init];
        flashSet.id = [rawSetData objectForKey:@"id"];
        flashSet.title= [rawSetData objectForKey:@"title"];
        
        NSTimeInterval timeInterval = [[rawSetData objectForKey:@"created_date"] doubleValue];
        flashSet.createdDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        timeInterval = [[rawSetData objectForKey:@"modified_date"] doubleValue];
        flashSet.modifiedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        //Fetch all the terms in the set
        
        NSArray* termsInSet = [rawSetData objectForKey:@"terms"];
        NSMutableSet* flashSetItems = [NSMutableSet set];
        
        for (NSDictionary* eachTermData in termsInSet) {
            FlashSetItemAttributes* setItem = [[FlashSetItemAttributes alloc] init];
            setItem.id = [eachTermData objectForKey:@"id"];
            setItem.term = [eachTermData objectForKey:@"term"];
            setItem.definition = [eachTermData objectForKey:@"definition"];
            
            [flashSetItems addObject:setItem];
        }
        
        [self updateFlashSet:flashSet withItems:flashSetItems];
        [returnSet addObject:flashSet];
    }
    
    return returnSet;
}

#pragma mark - Public methods
+(FlashSetLogic*)singleton
{
    static FlashSetLogic* sharedObj = nil;
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

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
    FlashSetInfo* requiredSet = [self getPersistentSetForId:setId];
    
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

-(NSArray*)downloadAllSetsForUserId:(UserInfoAttributes *)user;
{
    //TODO: Have to map them to the user
    NSURLRequest* request = [URLHelper getCreatedSetsRequestForUser:user.userId AccessToken:user.accessToken];
    
    NSSet* returnSet = [self downloadSetsForRequest:request];
    
    request = [URLHelper getFavoriteSetsRequestForUser:user.userId AccessToken:user.accessToken];
    
    returnSet = [returnSet setByAddingObjectsFromSet:[self downloadSetsForRequest:request]];
    
    return [returnSet allObjects];
}

@end
