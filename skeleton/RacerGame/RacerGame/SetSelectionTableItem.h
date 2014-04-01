//
//  SetSelectionTableItem.h
//  RacerGame
//
//  Created by Hunar Khanna on 1/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashSetInfoAttributes.h"

@interface SetSelectionTableItem : UITableViewCell

-(void)setDataSource:(FlashSetInfoAttributes*)flashSet;

@end
