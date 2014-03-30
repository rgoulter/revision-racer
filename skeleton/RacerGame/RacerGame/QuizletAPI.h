//
//  QuizletAPI.h
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QuizletLoginDelegate <NSObject>

@required

-(void)successfullyLoggedInForUserID;

@end

@interface QuizletAPI : NSObject<NSURLConnectionDataDelegate>

+(void)initiateLogin;

+(void)requestTokenFromAuthServerForUrl:(NSURL*)url;

@end
