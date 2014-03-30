//
//  ViewController.m
//  RacerGame
//
//  Created by Hunar Khanna on 20/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SetSelectorViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

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
    NSLog(@"New game button pressed..");
    
    //Launch segue to level/set selector
    UIStoryboard *storyboard = self.storyboard;
    SetSelectorViewController *setSelector = [storyboard instantiateViewControllerWithIdentifier:@"SetSelectorViewController"];
    
    [self.navigationController pushViewController:setSelector animated:YES];
}

@end
