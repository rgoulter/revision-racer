//
//  QuizletAPI.m
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "QuizletAPI.h"
#import "URLHelper.h"

@implementation QuizletAPI

+(void)initiateLogin
{
    NSURL *authURL = [URLHelper getLoginUrl];
    
    [[UIApplication sharedApplication] openURL:authURL];
}

+(void)requestTokenFromAuthServerForUrl:(NSURL *)url
{
    NSDictionary* parameterMap = [URLHelper getParameterDictionaryForURL:url];
    
    if ([parameterMap objectForKey:@"error"]) {
        //TODO: An error was encountered while logging in.
        //Do something on client-side??
    } else {
        NSString* authCode = [parameterMap objectForKey:@"code"];
        NSURLRequest *authRequest = [URLHelper getAuthRequestForCode:authCode];
        
        NSURLConnection *authConnection = [[NSURLConnection alloc] initWithRequest:authRequest delegate:self startImmediately:YES];
        
    }
}

+(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //TODO: Indicate successfully receive of data
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSLog(@"Access token : %@",[jsonData objectForKey:@"access_token"]);
    NSLog(@"User_id : %@",[jsonData objectForKey:@"user_id"]);
    NSLog(@"Expires in : %@",[jsonData objectForKey:@"expires_in"]);
}

+(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //TODO: Indicate error on UI side
    NSLog(@"Error while getting access token : %@",[error localizedDescription]);
}
@end
