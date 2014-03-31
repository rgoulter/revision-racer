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

@interface SetSelectorViewController ()

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
        
        // Set the Selected Set information for the game VC.
        // TODO
    }
}

#pragma mark - QuizletLoginDelegate methods
-(void)successfullyLoggedInForUserID:(UserInfoAttributes *)userInfo
{
    NSLog(@"Actually reached the delegate at destination");
    NSLog(@"Expiry date : %@", userInfo.expiryTimestamp);
    
    //Load previously persisted data
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
}

- (IBAction)beginGameBtnPressed:(UIButton *)sender {
    // TODO: Check whether a Revision FlashSet has been selected or not.
    // (Only perform the segue if there's a set to revise).
    
    [self performSegueWithIdentifier:@"setSelectionToGame" sender:self];
}
@end
