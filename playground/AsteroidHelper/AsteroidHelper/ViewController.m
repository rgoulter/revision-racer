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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"asterViewInMain"]) {
        self.asterDemoVC = segue.destinationViewController;
    }
}



- (IBAction)explodeAsterBtnPressed:(id)sender
{
}

- (IBAction)newAsterBtnPressed:(id)sender
{
    NSInteger idx = [self.generationType selectedRowInComponent:0];
    NSLog(@"Generate: %@", [[self generationMethods] objectAtIndex:idx]);
}



- (NSArray*)generationMethods
{
    NSArray *asterGenerationMethods = @[@"Cube",
                                        @"Truncated Icosahedron",
                                        @"Dodecahedron"];
    
    return asterGenerationMethods;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1; // For one column
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self generationMethods].count; // Numbers of rows
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self generationMethods] objectAtIndex:row]; // If it's a string
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected %@", [[self generationMethods] objectAtIndex:row]);
}

@end
