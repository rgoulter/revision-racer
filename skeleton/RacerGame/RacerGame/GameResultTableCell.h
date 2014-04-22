//
//  GameResultTableCell.h
//  RacerGame
//
//  Created by Hunar Khanna on 22/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameResultDetailsAttributes.h"

@interface GameResultTableCell : UITableViewCell

-(void)setBackingData:(GameResultDetailsAttributes *)backingData;

@end
