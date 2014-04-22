//
//  UserInfoLogic.m
//  RacerGame
//
//  Created by Hunar Khanna on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "UserInfoLogic.h"
#import "Resources.h"

@interface UserInfoLogic ()

@property(strong,nonatomic)NSManagedObjectContext* context;
-(UserInfo*)getUserInfoForId:(NSString*)userId;
-(BOOL)hasSessionExpired:(UserInfo*)userInfo;

@end

@implementation UserInfoLogic

#pragma mark - Getter methods -
-(NSManagedObjectContext *)context
{
    if (!_context) {
        _context = [Resources singleton].managedObjectContext;
    }
    return _context;
}

#pragma mark Public methods
+(UserInfoLogic*)singleton
{
    static UserInfoLogic* sharedObj = nil;
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

-(UserInfoAttributes *)getActiveUser
{
    //TODO: If session has expired, consider as inactive
    UserInfo* persistentObject = [self getPersistentActiveUser];
    
    if (!persistentObject) {
        return nil;
    }
    
    UserInfoAttributes* activeUser = [[UserInfoAttributes alloc] initWithUserInfo:persistentObject];
    
    return activeUser;
}

-(void)setActiveUser:(UserInfoAttributes *)newActiveUser
{
    //TODO: If doesnt exist in table, create
    //else update status in table to active
    UserInfo* oldActiveUser = [self getPersistentActiveUser];
    
    if (oldActiveUser) {
        //Set to non-active, if different
        //else update other properties
        if ([oldActiveUser.userId isEqualToString:newActiveUser.userId]) {
            oldActiveUser.accessToken = newActiveUser.accessToken;
            oldActiveUser.expiryTimestamp = newActiveUser.expiryTimestamp;
        } else {
            oldActiveUser.isActive = @(NO);
        }
    } else {
        //Create a new user, if user doesnt exist
        //else update
        UserInfo* newPersistentActiveUser = [self getUserInfoForId:newActiveUser.userId];
        if (!newPersistentActiveUser) {
            newPersistentActiveUser = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo"
                                                                    inManagedObjectContext:self.context];
            newPersistentActiveUser.userId = newActiveUser.userId;
        }
        newPersistentActiveUser.accessToken = newActiveUser.accessToken;
        newPersistentActiveUser.expiryTimestamp = newActiveUser.expiryTimestamp;
        newPersistentActiveUser.isActive = @(YES);
    }
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Problem while persisting UserInfo: %@", [error localizedDescription]);
    }
}

#pragma mark Private methods

-(UserInfo*)getUserInfoForId:(NSString*)userId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"userId = %@",userId];
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

-(UserInfo*)getPersistentActiveUser
{
    //Fetch the entry in the UserEntity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate* matchCondition = [NSPredicate predicateWithFormat:@"isActive = %@ AND expiryTimestamp > %@",@(YES), [NSDate date]];
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

-(void)logoutCurrentUser
{
    UserInfo* currentActiveUser = [self getPersistentActiveUser];
    currentActiveUser.isActive = @(NO);
    
    NSError* error;
    [self.context save:&error];
    
    if (error) {
        NSLog(@"Error encountered while logging out current user : %@",[error localizedDescription]);
    }
}

@end
