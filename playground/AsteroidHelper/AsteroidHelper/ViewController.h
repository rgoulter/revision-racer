//
//  ViewController.h
//  AsteroidHelper
//
//  Created by Richard Goulter on 13/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsteroidDemoViewController.h"

@interface ViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *generationType;
@property (weak, nonatomic) AsteroidDemoViewController *asterDemoVC;

@end
