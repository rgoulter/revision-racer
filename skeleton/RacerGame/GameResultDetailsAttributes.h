//
//  GameResultDetailsAttributes.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameResultDetails.h"

@interface GameResultDetailsAttributes : NSObject

@property (nonatomic, strong) NSNumber * correctGuesses;
@property (nonatomic, strong) NSNumber * flashCardId;
@property (nonatomic, strong) NSNumber * totalGuesses;

-(id)initWithGameResultDetails:(GameResultDetails*)details;

@end
