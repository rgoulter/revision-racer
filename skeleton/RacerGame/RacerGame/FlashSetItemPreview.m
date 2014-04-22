//
//  FlashSetItemPreview.m
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "FlashSetItemPreview.h"

@interface FlashSetItemPreview ()
@property (strong, nonatomic) IBOutlet UILabel *currentFaceType;
@property (strong, nonatomic) IBOutlet UILabel *currentFaceText;

@property (strong, nonatomic) FlashSetItemAttributes* backingSetItem;
@end

@implementation FlashSetItemPreview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setDataSource:(FlashSetItemAttributes *)item
{
    self.backingSetItem = item;
    [self.currentFaceType setText:@"Term"];
    [self.currentFaceText setText:self.backingSetItem.term];
}

-(void)flipCard
{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        if ([self.currentFaceType.text isEqualToString:@"Term"]) {
            [self.currentFaceType setText:@"Definition"];
            [self.currentFaceText setText:self.backingSetItem.definition];
        } else {
            [self.currentFaceType setText:@"Term"];
            [self.currentFaceText setText:self.backingSetItem.term];
        }
    } completion:NULL];
    
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
