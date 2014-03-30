//
//  QuizletAPI.m
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "QuizletAPI.h"
#import "URLFactory.h"

@implementation QuizletAPI

+(void)initiateLogin
{
    NSURL *authURL = [URLFactory getLoginUrl];
    
    [[UIApplication sharedApplication] openURL:authURL];
}

@end
