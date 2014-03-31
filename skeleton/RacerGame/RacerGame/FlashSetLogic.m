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

@interface FlashSetLogic ()

@property(strong,nonatomic)NSManagedObjectContext* context;
@end

@implementation FlashSetLogic

-(id)initWithManagedObjectContect:(NSManagedObjectContext *)context
{
    if (self = [super init]) {
        self.context = context;
    }
    return self;
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
