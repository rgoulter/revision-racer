//
//  FlashSetItemAttributes.m
//  RacerGame
//
//  Created by Hunar Khanna on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "FlashSetItemAttributes.h"

@implementation FlashSetItemAttributes

-(id)initWithFlashSetItem:(FlashSetItem *)item
{
    if (self = [super init]) {
        self.id = item.id;
        self.term = item.term;
        self.definition = item.definition;
    }
    return self;
}
@end
