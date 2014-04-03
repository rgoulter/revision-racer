//
//  FlashSetItemAttributes.h
//  RacerGame
//
//  Created by Hunar Khanna on 3/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashSetItem.h"

@interface FlashSetItemAttributes : NSObject

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * term;
@property (nonatomic, strong) NSString * definition;

-(id)initWithFlashSetItem:(FlashSetItem*)item;
@end
