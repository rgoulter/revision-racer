//
//  StyleManager.m
//  RacerGame
//
//  Created by Hunar Khanna on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "StyleManager.h"

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

-(NSAttributedString*)getAttributedTitleForString:(NSString*)text
{
    UIFont* font = [UIFont fontWithName:@"Georgia" size:69];
    NSMutableAttributedString* formattedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                      attributes:@{NSStrokeWidthAttributeName : @(-1),
                                                                                                   NSStrokeColorAttributeName : [UIColor whiteColor],
                                                                                                   NSForegroundColorAttributeName: [UIColor redColor],
                                                                                                   NSFontAttributeName : font}];
    return formattedText;
}

-(NSAttributedString *)getAttributedButtonTextForString:(NSString *)text
{
    UIFont* font = [UIFont fontWithName:@"Georgia-BoldItalic" size:16];
    NSMutableAttributedString* formattedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                      attributes:@{                                                                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                   NSFontAttributeName : font}];
    return formattedText;
}
@end
