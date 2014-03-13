//
//  ViewController.m
//  AsteroidHelper
//
//  Created by Richard Goulter on 13/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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

- (IBAction)newAsterButtonPressed:(id)sender {
    
}

- (IBAction)explodeAsterButtonPressed:(id)sender {
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1; // For one column
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3; // Numbers of rows
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *array = @[@"Cube",
                       @"Truncated Icosahedron",
                       @"Dodecahedron"];
    return [array objectAtIndex:row]; // If it's a string
}


@end
