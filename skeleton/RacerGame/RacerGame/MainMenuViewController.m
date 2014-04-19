//
//  ViewController.m
//  RacerGame
//
//  Created by Hunar Khanna on 20/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SetSelectorViewController.h"
#import "StyleManager.h"
#import "GameResultsLogic.h"
#import "GameResultDetailsAttributes.h"
#import "GameResultInfoAttributes.h"
#import "Resources.h"
#import "UserInfoLogic.h"

@interface MainMenuViewController ()
@property (strong, nonatomic) SetSelectorViewController* setSelectionViewController;
@property (strong, nonatomic) IBOutlet UIButton *customNewGameButton;
@end

@implementation MainMenuViewController

-(SetSelectorViewController *)setSelectionViewController
{
    if (!_setSelectionViewController) {
        UIStoryboard *storyboard = self.storyboard;
        _setSelectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"SetSelectorViewController"];
    }
    return _setSelectionViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:45.0f/225.0f green:57.0f/225.0f blue:86.0f/255.0f alpha:1.0];
    
    //Set Button text
    NSAttributedString* formattedText = [[StyleManager manager] getAttributedTitleForString:@"New game"];
    [self.customNewGameButton setAttributedTitle:formattedText forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGameButtonPressed:(id)sender {
    NSLog(@"Testing game results logic..");
    
    /*
    //Launch segue to level/set selector
    [self.navigationController pushViewController:self.setSelectionViewController
                                         animated:YES];
     */
   
    GameResultInfoAttributes* result = [[GameResultInfoAttributes alloc] init];
    result.score = @(20);
    result.playedDate = [NSDate date];
    result.setId = @(59);
    result.userId = [[UserInfoLogic singleton] getActiveUser].userId;
    
    NSMutableSet* detailsSet = [NSMutableSet set];
    
    for (int i = 1; i<=5; i++) {
        GameResultDetailsAttributes* newObj = [[GameResultDetailsAttributes alloc] init];
        newObj.flashCardId = @(i);
        newObj.totalGuesses = @(10);
        newObj.correctGuesses = @(4);
        
        [detailsSet addObject:newObj];
    }
    
    [[GameResultsLogic singleton] saveResults:result withDetails:detailsSet];
}

@end
