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

@interface SetSelectorViewController ()

@property (strong, nonatomic) IBOutlet UITableView *setTable;
@property (strong, nonatomic) NSArray* listOfUserSets;
@property (strong, nonatomic) FlashSetInfo* selectedSetForGame;
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
    [super viewDidLoad];
    
    [self.setTable setDataSource:self];
    [self.setTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SimpleCell"];
    [self.setTable setDelegate:self];
    UINib* customCellNib = [UINib nibWithNibName:@"SetSelectionTableItem" bundle:[NSBundle mainBundle]];
    [self.setTable registerNib:customCellNib forCellReuseIdentifier:@"CustomCell"];
    [self.setTable setRowHeight:100];
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

- (IBAction)signInUser:(id)sender {
    //Check if user is signed in
    //TODO: Read Quizlet API for expiring tokens/codes to initiate sign-ins
    
    QuizletAPI* quizletApi = [QuizletAPI quizletApi];
    quizletApi.delegate = self;
    [quizletApi initiateLogin];
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

#pragma mark - QuizletLoginDelegate methods
-(void)successfullyLoggedInForUserID:(UserInfoAttributes *)userInfo
{
    
    NSLog(@"Actually reached the delegate at destination");
    NSLog(@"Expiry date : %@", userInfo.expiryTimestamp);
    
    //Load previously persisted data
    /*
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (UserInfo* info in fetchedObjects) {
        NSLog(@"UserId: %@", info.userId);
        NSLog(@"Access Code: %@", info.accessToken);
    }
    
    //Persist all of this data
    /*
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    
    UserInfo* persistableAttribs = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
    
    persistableAttribs.expiryTimestamp = userInfo.expiryTimestamp;
    persistableAttribs.accessToken = userInfo.accessToken;
    persistableAttribs.userId = userInfo.userId;
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    */
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    FlashSetLogic* flashSetLogic = [[FlashSetLogic alloc] initWithManagedObjectContect:context];
    self.listOfUserSets = [flashSetLogic downloadSetsForUserId:userInfo];
    
    [self.setTable reloadData];
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
    FlashSetInfo* requiredSet = self.listOfUserSets[[indexPath item]];
    
    FlashSetInfoAttributes* attribs = [[FlashSetInfoAttributes alloc] init];
    attribs.title = requiredSet.title;
    attribs.createdDate = requiredSet.createdDate;
    attribs.modifiedDate = requiredSet.modifiedDate;
    attribs.id = requiredSet.id;
    
    SetSelectionTableItem* myCell = (SetSelectionTableItem*)defaultCell;
    [myCell setDataSource:attribs];
    
    return myCell;
}

@end
