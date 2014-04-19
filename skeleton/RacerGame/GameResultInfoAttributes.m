//
//  GameResultInfoAttributes.m
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultInfoAttributes.h"

@implementation GameResultInfoAttributes

-(id)initWithGameResultInfo:(GameResultInfo *)result
{
    if (self = [super init]) {
        self.playedDate = result.playedDate;
        self.score = result.score;
        self.setId = result.setId;
        self.userId = result.userId;
    }
    
    return self;
}
@end
