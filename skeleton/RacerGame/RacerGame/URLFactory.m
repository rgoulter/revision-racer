//
//  URLFactory.m
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "URLFactory.h"

#include "quizlet_secrets.inc"
#define REDIRECT_URI @"RacerGame:/"

#define LOGIN_URL @"https://quizlet.com/authorize"

@implementation URLFactory

+(NSURL*)getLoginUrl
{
    NSString *authorizeUrl = [NSString
                              stringWithFormat:@"%@?client_id=%@&response_type=code&scope=read&state=somestate&redirect_uri=%@",
                              LOGIN_URL, CLIENT_ID, REDIRECT_URI];
    return [NSURL URLWithString:authorizeUrl];
}

@end
