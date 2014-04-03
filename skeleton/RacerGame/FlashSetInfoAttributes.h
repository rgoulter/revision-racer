//
//  FlashSetInfoAttributes.h
//  RacerGame
//
//  Created by Hunar Khanna on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashSetInfo.h"

@interface FlashSetInfoAttributes : NSObject

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSDate * modifiedDate;
@property (nonatomic, strong) NSSet * cards;

-(id)initForFlashSetInfo:(FlashSetInfo*)flashSet;
@end
