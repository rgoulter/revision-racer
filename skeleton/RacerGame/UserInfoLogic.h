//
//  UserInfoLogic.h
//  RacerGame
//
//  Created by Hunar Khanna on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoAttributes.h"

@interface UserInfoLogic : NSObject

-(UserInfoAttributes*)getActiveUser;

-(void)setActiveUser:(UserInfoAttributes*)newActiveUser;

@end
