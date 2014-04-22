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
#import "SetSelectionTableItem.h"
#import "ActivityModal.h"
#import "Resources.h"
#import "NavigationButton.h"
#import "UserInfoLogic.h"
#import "StyleManager.h"
#import "FlashSetSummary.h"
#import "SetPreviewViewController.h"
#import "SignInButton.h"

@interface SetSelectorViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *flashSetCollection;
@property (strong, nonatomic) IBOutlet UIView *collectionViewBackground;
@property (strong, nonatomic) NSArray* listOfUserSets;
@property (strong, nonatomic) IBOutlet SignInButton *signInOutButton;
@property (strong, nonatomic) FlashSetInfoAttributes* selectedSetForGame;
@property (strong, nonatomic) ActivityModal* statusModal;
@property (strong, nonatomic) IBOutlet NavigationButton *backNavigation;
@property (strong, nonatomic) IBOutlet UIButton *setUpdateButton;
@property (strong, nonatomic) IBOutlet UIButton *setPreviewButton;
@property (strong, nonatomic) IBOutlet UILabel *emptyCollectionViewLabel;
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
    NSLog(@"Active user : %@",[[UserInfoLogic singleton] getActiveUser].userId);
    
    StyleManager* manager = [StyleManager manager];
    [self.backNavigation setAttributedTitle:[manager getAttributedButtonTextForString:@"Back"] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/225.0f green:57.0f/225.0f blue:86.0f/255.0f alpha:1.0];
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
        _statusModal = [[ActivityModal alloc] initWithFrame:self.view.frame];
    }
    
    return _statusModal;
}

#pragma mark - Setters
- (void)setListOfUserSets:(NSArray *)listOfUserSets
{
    _listOfUserSets = listOfUserSets;
    [self.flashSetCollection reloadData];
    
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
        // Set the Selected Set information for the game VC.
        // TODO
        // gameVC.flashSet = ...;
    }
}

- (void)downloadAllFlashSets:(UserInfoAttributes*)userInfo
{
    self.listOfUserSets = [[FlashSetLogic singleton] downloadAllSetsForUserId:userInfo];
    [self.statusModal removeFromSuperview];
    
    [self.flashSetCollection reloadData];
}

#pragma mark - QuizletLoginDelegate methods
-(void)successfullyLoggedInForUserID:(UserInfoAttributes *)userInfo
{
    
    NSLog(@"Actually reached the delegate at destination");
    NSLog(@"Expiry date : %@", userInfo.expiryTimestamp);
    
    [self.statusModal setText:@"Downloading your flash sets.."];
    [self performSelector:@selector(downloadAllFlashSets:) withObject:userInfo afterDelay:2];
    [self.signInOutButton refreshButtonText];
}

- (IBAction)beginGameBtnPressed:(UIButton *)sender {
    // TODO: Check whether a Revision FlashSet has been selected or not.
    // (Only perform the segue if there's a set to revise).
    
    [self performSegueWithIdentifier:@"setSelectionToGame" sender:self];
}

- (IBAction)updateButtonPressed:(id)sender {
    NSLog(@"Update button pressed");
}

- (IBAction)previewButtonPressed:(id)sender {
    NSLog(@"Preview button pressed");
    
    SetPreviewViewController* previewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPreviewViewController"];
    [previewViewController setFlashSetToPreview:self.selectedSetForGame];
    [self.navigationController pushViewController:previewViewController animated:YES];
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
    
    self.selectedSetForGame = self.listOfUserSets[[indexPath item]];
    NSLog(@"Cell %lu selected",[indexPath item]);
}

#pragma mark UICollectionViewDataSource delegate methods
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCell"
                                                                                 forIndexPath:indexPath];
    FlashSetInfoAttributes* requiredSet = self.listOfUserSets[[indexPath item]];
    
    FlashSetSummary* myCell = (FlashSetSummary*)customCell;
    [myCell setDataSource:requiredSet];
    return customCell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listOfUserSets count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

@end
