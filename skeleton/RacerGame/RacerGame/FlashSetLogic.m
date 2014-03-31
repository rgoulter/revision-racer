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

-(void)downloadSetsForUserId:(UserInfoAttributes *)user
{
    NSURLRequest* request = [URLHelper getCreatedSetsRequestForUser:user.userId AccessToken:user.accessToken];
    
    //TODO: Make async
    NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                             options:kNilOptions error:nil];
    
    for (NSDictionary* rawSetData in jsonData) {
        //TODO: See if another object exists for the same id
        //If it does and equal to current object, do nothing
        //If it does and uneqaul(use modified), update
        //If it does not exist, create
        NSNumber* id = [rawSetData objectForKey:@"id"];
        NSString* title= [rawSetData objectForKey:@"title"];
        NSDate* createdDate = [rawSetData objectForKey:@"created_date"];
        NSDate* modifiedDate = [rawSetData objectForKey:@"modified_date"];
        
    }
}


@end
