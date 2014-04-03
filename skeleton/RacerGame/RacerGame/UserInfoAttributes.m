//
//  UserInfoAttributes.m
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "UserInfoAttributes.h"

@implementation UserInfoAttributes

-(id)initWithUserInfo:(UserInfo *)userInfo
{
    if (self = [super init]) {
        self.expiryTimestamp = userInfo.expiryTimestamp;
        self.accessToken = userInfo.accessToken;
        self.userId = userInfo.userId;
    }
    return self;
}
@end
