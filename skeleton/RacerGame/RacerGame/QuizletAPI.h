//
//  QuizletAPI.h
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoAttributes.h"

@protocol QuizletLoginDelegate <NSObject>

@required

-(void)successfullyLoggedInForUserID:(UserInfoAttributes*)userInfo;

@end

@interface QuizletAPI : NSObject<NSURLConnectionDataDelegate>

@property(weak,nonatomic)id<QuizletLoginDelegate> delegate;

+(id)quizletApi;

-(void)initiateLogin;

-(void)requestTokenFromAuthServerForUrl:(NSURL*)url;

@end
