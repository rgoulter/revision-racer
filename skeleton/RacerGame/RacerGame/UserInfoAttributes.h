//
//  UserInfoAttributes.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface UserInfoAttributes : NSObject

@property (nonatomic, strong) NSDate * expiryTimestamp;
@property (nonatomic, strong) NSString * accessToken;
@property (nonatomic, strong) NSString * userId;

-(id)initWithUserInfo:(UserInfo*)userInfo;

@end
