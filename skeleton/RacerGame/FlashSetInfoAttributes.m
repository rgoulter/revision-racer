//
//  FlashSetInfoAttributes.m
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "FlashSetInfoAttributes.h"

@implementation FlashSetInfoAttributes

-(id)initForFlashSetInfo:(FlashSetInfo*)flashSet
{
    if (self = [super init]) {
        self.id = flashSet.id;
        self.title = flashSet.title;
        self.createdDate = flashSet.createdDate;
        self.modifiedDate = flashSet.modifiedDate;
        self.cards = flashSet.hasCards;
    }
    return self;
}
@end
