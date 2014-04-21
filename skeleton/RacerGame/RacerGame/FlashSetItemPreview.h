//
//  FlashSetItemPreview.h
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashSetItemAttributes.h"

@interface FlashSetItemPreview : UICollectionViewCell

-(void)setDataSource:(FlashSetItemAttributes*)item;
@end
