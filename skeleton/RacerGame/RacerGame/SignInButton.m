//
//  SignInButton.m
//  RacerGame
//
//  Created by Hunar Khanna on 22/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SignInButton.h"

@implementation SignInButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"Is this even called");
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 4;
        self.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:18];
        
        [self buttonReleased];
        [self setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

-(void)buttonPressed
{
    NSLog(@"Changing the background color to green");
    self.backgroundColor = [UIColor whiteColor];
}

-(void)buttonReleased
{
    NSLog(@"Changing the background color to white");
    self.backgroundColor = [UIColor greenColor];
    UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"LOl" delegate:nil cancelButtonTitle:@"Nopes" otherButtonTitles: nil];
    [myAlert show];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Is this even called");
    self.layer.cornerRadius = 4;
    // Drawing code
    
}
*/

@end
