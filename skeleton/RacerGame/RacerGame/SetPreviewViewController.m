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
#import "Constants.h"

@interface SetPreviewViewController ()
@property (strong, nonatomic) IBOutlet NavigationButton *backNavigation;
@property (strong, nonatomic) FlashSetInfoAttributes* backingFlashSet;
@property (strong, nonatomic) NSArray* setContents;
@property (strong, nonatomic) NSArray* filteredContents;
@property (strong, nonatomic) IBOutlet UICollectionView *setItemsCollection;
@property (strong, nonatomic) IBOutlet UIView *collectionViewBackground;
@property (strong, nonatomic) IBOutlet UILabel *previewTitleLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchField;

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

-(void)setSetContents:(NSArray *)setContents
{
    _setContents = setContents;
    self.filteredContents = setContents;
}

-(void)setFilteredContents:(NSArray *)filteredContents
{
    _filteredContents = filteredContents;
    [self.setItemsCollection reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    //Initialize the "Back" button
    StyleManager* manager = [StyleManager manager];
    [self.backNavigation setAttributedTitle:[manager getAttributedButtonTextForString:@"Back"]
                                   forState:UIControlStateNormal];
    
    //Get all the items in the set
    
    UICollectionViewFlowLayout* gridLayout = [[UICollectionViewFlowLayout alloc] init];
    gridLayout.minimumInteritemSpacing = 15;
    gridLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    UINib* customCellNib = [UINib nibWithNibName:@"FlashSetItemPreview" bundle:[NSBundle mainBundle]];
    [self.setItemsCollection registerNib:customCellNib forCellWithReuseIdentifier:@"PreviewCell"];
    
    UICollectionViewCell* item = [[[NSBundle mainBundle] loadNibNamed:@"FlashSetItemPreview" owner:nil options:nil] lastObject];
    gridLayout.itemSize = item.bounds.size;
    
    self.setItemsCollection.collectionViewLayout = gridLayout;
    [self.setItemsCollection setDataSource:self];
    [self.setItemsCollection setDelegate:self];
    [self.setItemsCollection setBackgroundColor:[UIColor clearColor]];
    
    self.collectionViewBackground.layer.cornerRadius = 10;
    
    //Set the preview mode title to set name
    [self.previewTitleLabel setText:self.backingFlashSet.title];
    
    //Set searchbar settings
    [self.searchField setDelegate:self];
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
    NSArray* unsortedArray = [[[FlashSetLogic singleton] getAllItemsInSet:self.backingFlashSet.id] allObjects];
    NSSortDescriptor* sortByTerm = [NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES];
    self.setContents = [unsortedArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByTerm]];
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

#pragma mark UISearchBarDelegate methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""] && searchText.length >= MINIMUM_SEARCH_STRING_LENGTH) {
        NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"term CONTAINS[cd] %@ OR definition CONTAINS[cd] %@",searchText,searchText];
        self.filteredContents = [self.setContents filteredArrayUsingPredicate:searchPredicate];
    } else {
        self.filteredContents = self.setContents;
    }
}

#pragma mark UICollectionViewDataSourceDelegate methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell"
                                                                                 forIndexPath:indexPath];
    FlashSetItemAttributes* requiredSet = self.filteredContents[[indexPath item]];
    
    FlashSetItemPreview* myCell = (FlashSetItemPreview*)customCell;
    [myCell setDataSource:requiredSet];
    return customCell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [self.filteredContents count];
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
