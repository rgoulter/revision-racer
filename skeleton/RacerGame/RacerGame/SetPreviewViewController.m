//
//  SetPreviewViewController.m
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SetPreviewViewController.h"
#import "NavigationButton.h"
#import "StyleManager.h"
#import "FlashSetLogic.h"
#import "FlashSetItemAttributes.h"
#import "FlashSetItemPreview.h"

@interface SetPreviewViewController ()
@property (strong, nonatomic) IBOutlet NavigationButton *backNavigation;
@property (strong, nonatomic) FlashSetInfoAttributes* backingFlashSet;
@property (strong, nonatomic) NSArray* setContents;
@property (strong, nonatomic) IBOutlet UICollectionView *setItemsCollection;
@property (strong, nonatomic) IBOutlet UIView *collectionViewBackground;

@end

@implementation SetPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *)setContents
{
    if (!_setContents) {
        _setContents = [[[FlashSetLogic singleton] getAllItemsInSet:self.backingFlashSet.id] allObjects];
    }
    return _setContents;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/225.0f green:57.0f/225.0f blue:86.0f/255.0f alpha:1.0];
    
    //Initialize the "Back" button
    StyleManager* manager = [StyleManager manager];
    [self.backNavigation setAttributedTitle:[manager getAttributedButtonTextForString:@"Back"]
                                   forState:UIControlStateNormal];
    
    //Get all the items in the set
    
    UICollectionViewFlowLayout* gridLayout = [[UICollectionViewFlowLayout alloc] init];
    gridLayout.minimumInteritemSpacing = 25;
    gridLayout.sectionInset = UIEdgeInsetsMake(15, 0, 15, 0);
    
    UINib* customCellNib = [UINib nibWithNibName:@"FlashSetItemPreview" bundle:[NSBundle mainBundle]];
    [self.setItemsCollection registerNib:customCellNib forCellWithReuseIdentifier:@"PreviewCell"];
    
    UICollectionViewCell* item = [[[NSBundle mainBundle] loadNibNamed:@"FlashSetItemPreview" owner:nil options:nil] lastObject];
    gridLayout.itemSize = item.bounds.size;
    
    self.setItemsCollection.collectionViewLayout = gridLayout;
    [self.setItemsCollection setDataSource:self];
    [self.setItemsCollection setDelegate:self];
    [self.setItemsCollection setBackgroundColor:[UIColor clearColor]];
    
    self.collectionViewBackground.layer.cornerRadius = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Public methods

-(void)setFlashSetToPreview:(FlashSetInfoAttributes *)flashSet
{
    self.backingFlashSet = flashSet;
}

#pragma mark Private Methods
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* customCell = [collectionView cellForItemAtIndexPath:indexPath];
    FlashSetItemPreview* myCell = (FlashSetItemPreview*)customCell;

    [myCell flipCard];
}

#pragma mark UICollectionViewDataSourceDelegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell"
                                                                                 forIndexPath:indexPath];
    FlashSetItemAttributes* requiredSet = self.setContents[[indexPath section]];
    
    FlashSetItemPreview* myCell = (FlashSetItemPreview*)customCell;
    [myCell setDataSource:requiredSet];
    return customCell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.setContents count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
