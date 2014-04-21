//
//  FlashSetSummary.h
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashSetInfoAttributes.h"

@interface FlashSetSummary : UICollectionViewCell

-(void)setDataSource:(FlashSetInfoAttributes*)flashSet;
@end
