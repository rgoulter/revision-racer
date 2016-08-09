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

+(id)loadWithFrame:(CGRect)frame
{
    // cf.
    // http://stackoverflow.com/questions/13534502/ios-loadnibnamed-confusion-what-is-best-practice
    // This code shouldn't be in 'initWithFrame', but +something.
    ActivityModal *activityModal = [[[NSBundle mainBundle] loadNibNamed:@"ActivityModal"
                                                                  owner:nil
                                                                options:nil] lastObject];

    if (activityModal) {
        // Initialization code
        CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
        activityModal.center = center;
        activityModal.visibleRect.layer.cornerRadius = 10.0;
        [activityModal.indicator startAnimating];
    }

    return activityModal;
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
