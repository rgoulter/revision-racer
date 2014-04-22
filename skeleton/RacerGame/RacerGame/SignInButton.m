//
//  SignInButton.m
//  RacerGame
//
//  Created by Hunar Khanna on 22/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SignInButton.h"
#import "UserInfoLogic.h"

#define CUSTOM_GREEN [UIColor colorWithRed:(51.0/255.0) green:(156.0/255.0) blue:(9.0/255.0) alpha:1.0]
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
        [self setTitleColor:CUSTOM_GREEN forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(buttonReleased) forControlEvents:UIControlEventTouchUpOutside];
        
        [self refreshButtonText];
    }
    return self;
}

-(void)refreshButtonText
{
    UserInfoAttributes* activeUser = [[UserInfoLogic singleton] getActiveUser];
    if (activeUser) {
        [self setTitle:activeUser.userId forState:UIControlStateNormal];
    } else {
        [self setTitle:@"Sign In" forState:UIControlStateNormal];
    }
}

-(void)buttonPressed
{
    self.backgroundColor = [UIColor whiteColor];
}

-(void)buttonReleased
{
    self.backgroundColor = CUSTOM_GREEN;
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
