//
//  GameResultDetails.h
//  RacerGame
//
//  Created by Hunar Khanna on 19/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GameResultDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * correctGuesses;
@property (nonatomic, retain) NSNumber * flashCardId;
@property (nonatomic, retain) NSNumber * totalGuesses;

@end
