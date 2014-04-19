//
//  GameResultInfoAttributes.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameResultInfo.h"

@interface GameResultInfoAttributes : NSObject

@property (nonatomic, strong) NSDate * playedDate;
@property (nonatomic, strong) NSNumber * score;
@property (nonatomic, strong) NSNumber * setId;
@property (nonatomic, strong) NSSet *hasDetails;

-(id)initWithGameResultInfo:(GameResultInfo*)result;

@end
