//
//  SetSelectorViewController.m
//  RacerGame
//
//  Created by Hunar Khanna on 30/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SetSelectorViewController.h"
#import "QuizletAPI.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "GameViewController.h"
#import "FlashSetLogic.h"
#import "ActivityModal.h"
#import "Resources.h"
#import "NavigationButton.h"
#import "UserInfoLogic.h"
#import "StyleManager.h"
#import "FlashSetSummary.h"
#import "SetPreviewViewController.h"
#import "SignInButton.h"
#import "Constants.h"

@interface SetSelectorViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *flashSetCollection;
@property (strong, nonatomic) IBOutlet UIView *collectionViewBackground;
@property (strong, nonatomic) NSArray* listOfUserSets;
@property (strong, nonatomic) NSArray* filteredResults;
@property (strong, nonatomic) IBOutlet SignInButton *signInOutButton;
@property (strong, nonatomic) FlashSetInfoAttributes* selectedSetForGame;
@property (strong, nonatomic) ActivityModal* statusModal;
@property (strong, nonatomic) IBOutlet NavigationButton *backNavigation;
@property (strong, nonatomic) IBOutlet UIButton *setUpdateButton;
@property (strong, nonatomic) IBOutlet UIButton *setPreviewButton;
@property (strong, nonatomic) IBOutlet UIButton *updateAllButton;
@property (strong, nonatomic) IBOutlet NavigationButton *startGameButton;
@property (strong, nonatomic) IBOutlet UILabel *emptyCollectionViewLabel;

@property (strong, nonatomic) IBOutlet UISearchBar *searchField;

@property (nonatomic) BOOL isTrainingMode;
-(void)hideActivityModal;
- (void)downloadAllFlashSets:(UserInfoAttributes*)userInfo;
@end

@implementation SetSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    StyleManager* manager = [StyleManager manager];
    [self.backNavigation setAttributedTitle:[manager getAttributedButtonTextForString:@"Back"] forState:UIControlStateNormal];
    [self.startGameButton setAttributedTitle:[manager getAttributedButtonTextForString:@"Start Game"] forState:UIControlStateNormal];
    
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    [super viewDidLoad];
    
    self.listOfUserSets = [[FlashSetLogic singleton] getSetsOfActiveUser];

    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout* gridLayout = [[UICollectionViewFlowLayout alloc] init];
    gridLayout.minimumInteritemSpacing = 5;
    gridLayout.sectionInset = UIEdgeInsetsMake(15, 45, 15, 45);

    UINib* customCellNib = [UINib nibWithNibName:@"FlashSetSummary" bundle:[NSBundle mainBundle]];
    [self.flashSetCollection registerNib:customCellNib forCellWithReuseIdentifier:@"CustomCell"];
    
    UICollectionViewCell* item = [[[NSBundle mainBundle] loadNibNamed:@"FlashSetSummary" owner:nil options:nil] lastObject];
    gridLayout.itemSize = item.bounds.size;
    
    self.flashSetCollection.collectionViewLayout = gridLayout;
    [self.flashSetCollection setDataSource:self];
    [self.flashSetCollection setDelegate:self];
    [self.flashSetCollection setBackgroundColor:[UIColor clearColor]];
    
    self.collectionViewBackground.layer.cornerRadius = 10;
    
    //Disable update/preview buttons when view is first loaded
    [self.setPreviewButton setEnabled:NO];
    [self.setUpdateButton setEnabled:NO];
    [self.startGameButton setEnabled:NO];
    self.startGameButton.backgroundColor = BUTTON_DISABLED_COLOR;
    
    //Set the default values
    self.isTrainingMode = NO;
    
    //Set search bar delegate
    [self.searchField setDelegate:self];
    [self.searchField setBackgroundImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initiateLogin
{
    QuizletAPI* quizletApi = [QuizletAPI quizletApi];
    quizletApi.delegate = self;
    [quizletApi initiateLogin];
}

- (IBAction)gameModeSwitchPressed:(id)sender {
    UISegmentedControl* modeSelectControl = (UISegmentedControl*)sender;
    if ([modeSelectControl selectedSegmentIndex] == 1) {
        self.isTrainingMode = NO;
    } else {
        self.isTrainingMode = YES;
    }
}

- (IBAction)signInUser:(id)sender {
    //Check if user is signed in
    //TODO: Read Quizlet API for expiring tokens/codes to initiate sign-ins
    UserInfoAttributes* activeUser = [[UserInfoLogic singleton] getActiveUser];
    if (activeUser) {
        UIAlertView* logoutAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm Logout?"
                                                                  message:@"Are you sure you wish to logout?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"YES"
                                                        otherButtonTitles:@"NO", nil];
        [logoutAlertView show];
    } else {
        [self.statusModal setText:@"Logging in to Quizlet.."];
        [self.view addSubview:self.statusModal];
        
        [self performSelector:@selector(initiateLogin) withObject:nil afterDelay:2];
    }
}

#pragma mark - Getters
- (ActivityModal *)statusModal
{
    if (!_statusModal) {
        _statusModal = [ActivityModal loadWithFrame:self.view.frame];
    }
    
    return _statusModal;
}

#pragma mark - Setters
- (void)setListOfUserSets:(NSArray *)listOfUserSets
{
    _listOfUserSets = listOfUserSets;
    self.filteredResults = listOfUserSets;
    [self.searchField setText:@""];
    //[self.flashSetCollection reloadData];
    
    if (!self.listOfUserSets || ([self.listOfUserSets count] == 0)) {
        if (![[UserInfoLogic singleton] getActiveUser]) {
            [self.emptyCollectionViewLabel setText:@"You are not logged to any Quizlet account"];
        } else {
            [self.emptyCollectionViewLabel setText:@"You are currently do not have any sets in your account"];
        }
    } else {
        [self.emptyCollectionViewLabel setText:@""];
    }
    
    //By default
    [self.setUpdateButton setEnabled:NO];
    [self.setPreviewButton setEnabled:NO];
    [self.startGameButton setEnabled:NO];
    if (!listOfUserSets || [listOfUserSets count] == 0) {
        [self.updateAllButton setEnabled:NO];
    } else {
        [self.updateAllButton setEnabled:YES];
    }
    self.startGameButton.backgroundColor = [UIColor colorWithRed:(201.0/255.0) green:(201.0/255.0) blue:(201.0/255.0) alpha:1.0];
}

-(void)setFilteredResults:(NSArray *)filteredResults
{
    _filteredResults = filteredResults;
    [self.flashSetCollection reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Setup the transition for set selection to game
    if ([segue.identifier isEqualToString:@"setSelectionToGame"]) {
        GameViewController *gameVC = (GameViewController*)segue.destinationViewController;
        
        gameVC.flashSet = self.selectedSetForGame;
        
        // Set default or training mode
        gameVC.gameRules = self.isTrainingMode ? [GameRules trainingModeGameRules] : [GameRules defaultGameRules];
    }
}

- (void)downloadAllFlashSets:(UserInfoAttributes*)userInfo
{
    [[FlashSetLogic singleton] downloadAllSetsForUserId:userInfo];
    self.listOfUserSets = [[FlashSetLogic singleton] getSetsOfActiveUser];
    [self.statusModal removeFromSuperview];
}

#pragma mark - QuizletLoginDelegate methods
-(void)successfullyLoggedInForUserID:(UserInfoAttributes *)userInfo
{
    [self.statusModal setText:@"Downloading your flash sets.."];
    [self performSelector:@selector(downloadAllFlashSets:) withObject:userInfo afterDelay:2];
    [self.signInOutButton refreshButtonText];
}

-(IBAction)updateAllFlashSets:(id)sender
{
    [self.view addSubview:self.statusModal];
    [self.statusModal setText:@"Updating all your flash sets.."];
    UserInfoAttributes* activeUser = [[UserInfoLogic singleton] getActiveUser];
    [self downloadAllFlashSets:activeUser];
}

- (IBAction)beginGameBtnPressed:(UIButton *)sender {
    
    if([[[FlashSetLogic singleton] getAllItemsInSet:self.selectedSetForGame.id] count] < 5) {
        UIAlertView* insufficientSetItemsAlert = [[UIAlertView alloc] initWithTitle:@"Cannot play" message:@"You need a set with at least 5 cards to play the game!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [insufficientSetItemsAlert show];
    } else {
        [self performSegueWithIdentifier:@"setSelectionToGame" sender:self];
    }
}

- (IBAction)updateButtonPressed:(id)sender {
    [self.statusModal setText:[NSString stringWithFormat:@"Syncing data of set\n\"%@\"",self.selectedSetForGame.title]];
    [self.view addSubview:self.statusModal];
    
    SyncResponse backendResponse = [[FlashSetLogic singleton] syncServerDataOfSet:self.selectedSetForGame.id];
    
    [self performSelector:@selector(hideActivityModal) withObject:self afterDelay:2];
    
    if (backendResponse == ERROR) {
        NSLog(@"Error encountered while updating the set");
    } else {
        self.listOfUserSets = [[FlashSetLogic singleton] getSetsOfActiveUser];
    }
}

- (IBAction)previewButtonPressed:(id)sender {
    SetPreviewViewController* previewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPreviewViewController"];
    [previewViewController setFlashSetToPreview:self.selectedSetForGame];
    [self.navigationController pushViewController:previewViewController animated:YES];
}

#pragma mark UISearchBarDelegate methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""] && searchText.length >= MINIMUM_SEARCH_STRING_LENGTH) {
        NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@",searchText];
        self.filteredResults = [self.listOfUserSets filteredArrayUsingPredicate:filterPredicate];
    } else {
        self.filteredResults = self.listOfUserSets;
    }
}

#pragma mark UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //"Yes" clicked
    if (buttonIndex == 0) {
        //Initiate logout
        [[UserInfoLogic singleton] logoutCurrentUser];
        self.listOfUserSets = nil;
        [self.signInOutButton refreshButtonText];
    }
}

#pragma mark UICollectionViewDelegate methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.setUpdateButton setEnabled:YES];
    [self.setPreviewButton setEnabled:YES];
    [self.startGameButton setEnabled:YES];
    self.startGameButton.backgroundColor = BUTTON_ENABLED_COLOR;
    
    self.selectedSetForGame = self.filteredResults[[indexPath item]];
}

#pragma mark UICollectionViewDataSource delegate methods
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCell"
                                                                                 forIndexPath:indexPath];
    FlashSetInfoAttributes* requiredSet = self.filteredResults[[indexPath item]];
    
    FlashSetSummary* myCell = (FlashSetSummary*)customCell;
    [myCell setDataSource:requiredSet];
    return customCell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filteredResults count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(void)hideActivityModal
{
    [self.statusModal removeFromSuperview];
}
@end
