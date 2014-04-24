//
//  NavigationButton.m
//  RacerGame
//
//  Created by Hunar Khanna on 18/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "NavigationButton.h"
#import "Constants.h"

@implementation NavigationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])){
        
        [self setTitle:@"Default" forState:UIControlStateNormal];
        self.backgroundColor = BUTTON_ENABLED_COLOR;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
}


@end
