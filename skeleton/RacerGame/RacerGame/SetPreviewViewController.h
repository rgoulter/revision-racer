//
//  SetPreviewViewController.h
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashSetInfoAttributes.h"

@interface SetPreviewViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

-(void)setFlashSetToPreview:(FlashSetInfoAttributes*)flashSet;

@end
