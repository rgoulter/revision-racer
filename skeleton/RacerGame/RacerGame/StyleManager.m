//
//  StyleManager.m
//  RacerGame
//
//  Created by Hunar Khanna on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "StyleManager.h"
#import "Constants.h"

@implementation StyleManager

+(StyleManager *)manager
{
    static StyleManager* sharedObj = nil;
    @synchronized(self) {
        if (sharedObj == nil) {
            sharedObj = [[self alloc] init];
        }
    }
    return sharedObj;
}

-(NSAttributedString *)getAttributedButtonTextForString:(NSString *)text
{
    UIFont* font = REGULAR_BUTTON_FONT;
    NSMutableAttributedString* formattedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                      attributes:@{                                                                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                   NSFontAttributeName : font}];
    return formattedText;
}
@end
