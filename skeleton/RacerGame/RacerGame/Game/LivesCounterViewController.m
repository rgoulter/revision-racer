//
//  LivesCounterViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "LivesCounterViewController.h"

@interface LivesCounterViewController ()

@end

@implementation LivesCounterViewController {
    int _numLives;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //UINib *nib = [UINib nibWithNibName:@"SpaceShipIconView" bundle:nil];
        //[self.livesCollectionView registerNib:nib forCellWithReuseIdentifier:@"SpaceShipIconCell"];
        
        _numLives = 5;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Because UICollectionView is buggy.
    self.livesCollectionView.backgroundColor = [UIColor clearColor];
    self.livesCollectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return _numLives;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =
        [cv dequeueReusableCellWithReuseIdentifier:@"SpaceShipCollectionViewCell" forIndexPath:indexPath];
    return cell;
}

- (int)numLives
{
    return _numLives;
}

- (void)setNumLives:(int)numLives
{
    [self.livesCollectionView reloadData];
    _numLives = numLives;
}



@end
