//
//  StyleManager.h
//  RacerGame
//
//  Created by Hunar Khanna on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StyleManager : NSObject

+(StyleManager*)manager;

-(NSAttributedString*)getAttributedButtonTextForString:(NSString *)text;
@end
