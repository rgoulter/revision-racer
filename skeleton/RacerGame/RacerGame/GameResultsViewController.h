//
//  GameResultsViewController.h
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameResultsViewController : UIViewController<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;

@end
