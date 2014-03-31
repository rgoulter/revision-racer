//
//  URLFactory.m
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "URLHelper.h"

#include "quizlet_secrets.inc"
#define REDIRECT_URI @"RacerGame:/"

#define LOGIN_URL @"https://quizlet.com/authorize"
#define CREATED_SETS_URL @"https://api.quizlet.com/2.0/users/%@/sets"
#define TOKEN_URL @"https://api.quizlet.com/oauth/token"

@implementation URLHelper

+(NSURL*)getLoginUrl
{
    NSString *authorizeUrl = [NSString
                              stringWithFormat:@"%@?client_id=%@&response_type=code&scope=read&state=somestate&redirect_uri=%@",
                              LOGIN_URL, CLIENT_ID, REDIRECT_URI];
    return [NSURL URLWithString:authorizeUrl];
}

+(NSDictionary*)getParameterDictionaryForURL:(NSURL*)url
{
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [[url query] componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    return queryStringDictionary;
}

+(NSURLRequest *)getAuthRequestForCode:(NSString *)code
{
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:TOKEN_URL]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Basic %@", ENCODED_VALUE] forHTTPHeaderField:@"Authorization"];
    
    NSString *postBodyString = [NSString
                                stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@", code, REDIRECT_URI];
    NSData *postBody = [postBodyString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postBody];
    
    return request;
}

+(NSURLRequest*)getCreatedSetsRequestForUser:(NSString*)userId AccessToken:(NSString*)token;
{
    NSString* requiredURL = [NSString stringWithFormat:CREATED_SETS_URL, userId];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:requiredURL]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    
    return request;
}

@end
