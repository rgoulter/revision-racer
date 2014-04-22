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
#import "FlashSetItem.h"
#import "Resources.h"
#import "UserInfoLogic.h"

@interface FlashSetLogic ()

@property(strong,nonatomic)NSManagedObjectContext* context;

-(NSDate*)convertNumToDate:(NSNumber*)numDate;

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
    UserInfo* activeUser = [[UserInfoLogic singleton] getPersistentActiveUser];
    FlashSetInfo* persistentFlashSet = [self getPersistentSetForId:flashSet.id];
    
    if(persistentFlashSet) {
        [activeUser removeCanSeeObject:persistentFlashSet];
        [self.context deleteObject:persistentFlashSet];
        
        NSError* errorWhileDeletingSet = nil;
        [self.context save:&errorWhileDeletingSet];
        if (errorWhileDeletingSet) {
            NSLog(@"Error encountered : %@",[errorWhileDeletingSet localizedDescription]);
        }
    }
    persistentFlashSet = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetInfo"
                                                            inManagedObjectContext:self.context];
    persistentFlashSet.id = flashSet.id;
    persistentFlashSet.modifiedDate = flashSet.modifiedDate;
    persistentFlashSet.createdDate = flashSet.createdDate;
    persistentFlashSet.title = flashSet.title;
    
    for (FlashSetItemAttributes* eachCard in setOfCards) {
        FlashSetItem* persistableFlashSetItem = [self getPersistentSetItemForId:eachCard.id];
        
        persistableFlashSetItem = [NSEntityDescription insertNewObjectForEntityForName:@"FlashSetItem"
                                                                    inManagedObjectContext:self.context];
        persistableFlashSetItem.id = eachCard.id;
        persistableFlashSetItem.term = eachCard.term;
        persistableFlashSetItem.definition = eachCard.definition;

        [persistentFlashSet addHasCardsObject:persistableFlashSetItem];
    }
    
    [activeUser addCanSeeObject:persistentFlashSet];
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Problem while persisting Flash set and items: %@", [error debugDescription]);
    }
}

-(NSSet*)downloadSetsForRequest:(NSURLRequest*)request
{
    NSMutableSet* returnSet = [NSMutableSet set];
    
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                        options:kNilOptions
                                                          error:nil];
    
    for (NSDictionary* rawSetData in jsonData) {
        
        FlashSetInfoAttributes* flashSet = [[FlashSetInfoAttributes alloc] init];
        flashSet.id = [rawSetData objectForKey:@"id"];
        flashSet.title= [rawSetData objectForKey:@"title"];
        
        flashSet.createdDate = [self convertNumToDate:[rawSetData objectForKey:@"created_date"]];
        
        flashSet.modifiedDate = [self convertNumToDate:[rawSetData objectForKey:@"modified_date"]];
        
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

-(FlashSetItemAttributes*)getSetItemForId:(NSNumber*)flashCardId
{
    FlashSetItem* persistentItem = [self getPersistentSetItemForId:flashCardId];
    if (!persistentItem) {
        return [[FlashSetItemAttributes alloc] initWithFlashSetItem:persistentItem];
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
    
    NSSortDescriptor* sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return [[returnSet allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByName]];
}

-(NSArray*)getSetsOfActiveUser
{
    UserInfo* activeUser = [[UserInfoLogic singleton] getPersistentActiveUser];
    
    NSSet* activeUsersSets = [activeUser canSee];
    NSMutableArray* returnList = [NSMutableArray array];
    
    for (FlashSetInfo* eachSet in activeUsersSets) {
        FlashSetInfoAttributes* attribObject = [[FlashSetInfoAttributes alloc] initWithFlashSetInfo:eachSet];
        [returnList addObject:attribObject];
    }
    
    NSSortDescriptor* sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return [returnList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByName]];
}


-(SyncResponse)syncServerDataOfSet:(NSNumber *)setId
{
    UserInfo* activeUser = [[UserInfoLogic singleton] getPersistentActiveUser];
    //Make a request to get the details of this set
    
    NSURLRequest* setDownloadRequest = [URLHelper getSetDetailsRequestForSet:setId AccessToken:activeUser.accessToken];
    NSError* errorWhileDownloading = nil;
    NSData* response = [NSURLConnection sendSynchronousRequest:setDownloadRequest returningResponse:nil error:&errorWhileDownloading];
    
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                        options:kNilOptions
                                                          error:nil];
    if (errorWhileDownloading) {
        return ERROR;
    }
    
    /*
     Check for the following cases:
     1. Updating a set which has been deleted on the server but present locally
     2. Deleting/adding terms which have been deleted on server
     3. Error in case of network error
     */
    
    
    NSLog(@"Downloaded json data : %@",jsonData);
    NSString* errorInJson = [jsonData objectForKey:@"error"];
    NSLog(@"Error string : %@",errorInJson);
    //Delete this set
    if ([errorInJson isEqualToString:@"not_found"]) {
        FlashSetInfo* flashSet = [self getPersistentSetForId:setId];
        [self.context deleteObject:flashSet];
        
        NSError* errorWhileDeletingLocally = nil;
        [self.context save:&errorWhileDeletingLocally];
        
        //TODO: Possibly use status codes
        if (errorWhileDeletingLocally) {
            NSLog(@"Error encounter while deleting local data : %@",[errorWhileDeletingLocally localizedDescription]);
        }
        return DELETED;
    }
    
    
    FlashSetInfoAttributes* setToBeUpdated = [[FlashSetInfoAttributes alloc] init];
    setToBeUpdated.modifiedDate = [self convertNumToDate:[jsonData objectForKey:@"modified_date"]];
    setToBeUpdated.title = [jsonData objectForKey:@"title"];
    setToBeUpdated.createdDate = [self convertNumToDate:[jsonData objectForKey:@"created_date"]];
    setToBeUpdated.id = [jsonData objectForKey:@"id"];
    
    NSLog(@"Modified date : %@",setToBeUpdated.modifiedDate);
    NSLog(@"ID : %@",setToBeUpdated.id);
    NSLog(@"Title : %@",setToBeUpdated.title);
    NSLog(@"Created date : %@",setToBeUpdated.createdDate);
    
    NSArray* downloadedTerms = [jsonData objectForKey:@"terms"];
    NSMutableSet* setTerms = [NSMutableSet set];
    for (NSDictionary* eachTerm in downloadedTerms) {
        FlashSetItemAttributes* termAttribs = [[FlashSetItemAttributes alloc] init];
        termAttribs.id = [eachTerm objectForKey:@"id"];
        termAttribs.term = [eachTerm objectForKey:@"term"];
        termAttribs.definition = [eachTerm objectForKey:@"definition"];

        [setTerms addObject:termAttribs];
    }
    
    [self updateFlashSet:setToBeUpdated withItems:setTerms];
    
    return UPDATED;
}

#pragma mark Private methods

-(NSDate *)convertNumToDate:(NSNumber *)numDate
{
    NSTimeInterval interval = [numDate doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}
@end
