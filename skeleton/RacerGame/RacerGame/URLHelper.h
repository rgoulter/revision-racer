//
//  URLFactory.h
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLHelper : NSObject

+(NSURL*)getLoginUrl;

+(NSDictionary*)getParameterDictionaryForURL:(NSURL*)url;

+(NSURLRequest*)getAuthRequestForCode:(NSString*)code;

+(NSURLRequest*)getCreatedSetsRequestForUser:(NSString*)userId AccessToken:(NSString*)token;

+(NSURLRequest*)getFavoriteSetsRequestForUser:(NSString*)userId AccessToken:(NSString*)token;
@end
