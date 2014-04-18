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
#import "UserInfoLogic.h"

@interface SetSelectorViewController ()

@property (strong, nonatomic) IBOutlet UITableView *setTable;
@property (strong, nonatomic) NSArray* listOfUserSets;
@property (strong, nonatomic) FlashSetInfoAttributes* selectedSetForGame;
@property (strong, nonatomic) ActivityModal* statusModal;
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
    
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/225.0f green:57.0f/225.0f blue:86.0f/255.0f alpha:1.0];
    [super viewDidLoad];
    
    self.listOfUserSets = [[FlashSetLogic singleton] getSetsOfActiveUser];
    
    [self.setTable setDataSource:self];
    [self.setTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SimpleCell"];
    [self.setTable setDelegate:self];
    UINib* customCellNib = [UINib nibWithNibName:@"SetSelectionTableItem" bundle:[NSBundle mainBundle]];
    [self.setTable registerNib:customCellNib forCellReuseIdentifier:@"CustomCell"];
    
    SetSelectionTableItem* item = [[[NSBundle mainBundle] loadNibNamed:@"SetSelectionTableItem" owner:nil options:nil] lastObject];
    
    
    [self.setTable setRowHeight:item.bounds.size.height];
    
    // Do any additional setup after loading the view.
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
    [self.statusModal setText:@"Logging in to Quizlet.."];
    [self.view addSubview:self.statusModal];
    
    [self performSelector:@selector(initiateLogin) withObject:nil afterDelay:2];
}

#pragma mark - Getters
- (ActivityModal *)statusModal
{
    if (!_statusModal) {
        _statusModal = [[ActivityModal alloc] initWithFrame:self.view.frame];
    }
    
    return _statusModal;
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
    
    [self.setTable reloadData];
}

#pragma mark - QuizletLoginDelegate methods
-(void)successfullyLoggedInForUserID:(UserInfoAttributes *)userInfo
{
    
    NSLog(@"Actually reached the delegate at destination");
    NSLog(@"Expiry date : %@", userInfo.expiryTimestamp);
    
    [self.statusModal setText:@"Downloading your flash sets.."];
    [self performSelector:@selector(downloadAllFlashSets:) withObject:userInfo afterDelay:2];
}

- (IBAction)beginGameBtnPressed:(UIButton *)sender {
    // TODO: Check whether a Revision FlashSet has been selected or not.
    // (Only perform the segue if there's a set to revise).
    
    [self performSegueWithIdentifier:@"setSelectionToGame" sender:self];
}

#pragma mark UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedSetForGame = self.listOfUserSets[[indexPath item]];
}

#pragma mark UITableViewDataSource delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listOfUserSets count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* defaultCell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    //UITableViewCell* defaultCell = [tableView dequeueReusableCellWithIdentifier:<#(NSString *)#>]
    FlashSetInfoAttributes* requiredSet = self.listOfUserSets[[indexPath item]];
    
    SetSelectionTableItem* myCell = (SetSelectionTableItem*)defaultCell;
    [myCell setDataSource:requiredSet];
    
    return myCell;
}

@end
