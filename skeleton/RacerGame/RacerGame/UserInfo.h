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

@property (nonatomic, retain) NSDate * expiryTimestamp;
@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSString * userId;

@end
