//
//  FlashSetSummary.m
//  RacerGame
//
//  Created by Hunar Khanna on 21/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "FlashSetSummary.h"

@interface FlashSetSummary ()
@property (strong, nonatomic) IBOutlet UILabel *setName;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdatedText;

@property (strong, nonatomic) FlashSetInfoAttributes *backingData;

@end

@implementation FlashSetSummary

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDataSource:(FlashSetInfoAttributes *)flashSet
{
    self.backingData = flashSet;
}

-(void)setSelected:(BOOL)selected
{
    self.layer.borderWidth = 5;
    if (selected) {
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

-(void)setBackingData:(FlashSetInfoAttributes *)backingData
{
    _backingData = backingData;
    
    
    [self.setName setText: backingData.title];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *sgLocale = [NSLocale currentLocale];
    [dateFormatter setLocale:sgLocale];
    
    [dateFormatter setDoesRelativeDateFormatting:YES];
    NSString* dateString = [dateFormatter stringFromDate:backingData.modifiedDate];
    
    NSString* lastUpdatedString = [NSString stringWithFormat:@"Last updated : %@",dateString];
    [self.lastUpdatedText setText:lastUpdatedString];
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
