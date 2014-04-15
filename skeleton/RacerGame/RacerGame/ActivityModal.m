//
//  ActivityModal.m
//  RacerGame
//
//  Created by Hunar Khanna on 2/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "ActivityModal.h"

@interface ActivityModal ()
@property (strong, nonatomic) IBOutlet UILabel *activityText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIView *visibleRect;


@end

@implementation ActivityModal

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ActivityModal"
                                          owner:nil
                                        options:nil] lastObject];
    if (self) {
        // Initialization code
        CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.center = center;
        self.visibleRect.layer.cornerRadius = 10.0;
        [self.indicator startAnimating];
    }
    return self;
}

-(void)awakeFromNib
{
    
}

-(void)setText:(NSString *)text
{
    [self.activityText setText:text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
