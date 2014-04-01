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
@property (strong, nonatomic) SetSelectorViewController* setSelectionViewController;
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
    NSLog(@"New game button pressed..");
    
    //Launch segue to level/set selector
    [self.navigationController pushViewController:self.setSelectionViewController animated:YES];
}

@end
