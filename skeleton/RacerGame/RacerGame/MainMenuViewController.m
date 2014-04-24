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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGameButtonPressed:(id)sender {
    //Launch segue to level/set selector
    [self.navigationController pushViewController:self.setSelectionViewController
                                         animated:YES];
     
}

@end
