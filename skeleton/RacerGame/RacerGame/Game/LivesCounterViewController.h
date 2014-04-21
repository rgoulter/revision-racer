//
//  LivesCounterViewController.h
//  RacerGame
//
//  Created by Richard Goulter on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LivesCounterViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *livesCollectionView;

@property int numLives;

@end
