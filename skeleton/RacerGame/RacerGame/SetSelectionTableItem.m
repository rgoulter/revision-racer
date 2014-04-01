//
//  SetSelectionTableItem.m
//  RacerGame
//
//  Created by Hunar Khanna on 1/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "SetSelectionTableItem.h"

@interface SetSelectionTableItem ()
@property (strong, nonatomic) IBOutlet UILabel *setTitle;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdatedText;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

@property (strong, nonatomic) FlashSetInfoAttributes* backingData;
@end

@implementation SetSelectionTableItem

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataSource:(FlashSetInfoAttributes *)flashSet
{
    self.backingData = flashSet;
    
    [self.setTitle setText:self.backingData.title];
    NSString* lastUpdatedString = [NSString stringWithFormat:@"Last updated on %@",self.backingData.modifiedDate];
    [self.lastUpdatedText setText:lastUpdatedString];

}

- (IBAction)updateButtonPressed:(id)sender {
    NSLog(@"Update set button pressed");
}
@end
