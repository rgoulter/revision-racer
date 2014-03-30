//
//  UserInfo.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, strong) NSNumber * expiryTimestamp;
@property (nonatomic, strong) NSString * accessToken;
@property (nonatomic, strong) NSString * userId;

@end
