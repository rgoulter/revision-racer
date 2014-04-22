//
//  GameResultTableCell.m
//  RacerGame
//
//  Created by Hunar Khanna on 22/4/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultTableCell.h"
#import "FlashSetLogic.h"
#import "FlashSetItemAttributes.h"

@interface GameResultTableCell ()
@property (strong, nonatomic) IBOutlet UILabel *setTerm;
@property (strong, nonatomic) IBOutlet UILabel *numOfCorrectAnswers;
@property (strong, nonatomic) IBOutlet UILabel *totalGuessesLabel;

@property (strong, nonatomic) GameResultDetailsAttributes* backingData;
@end

@implementation GameResultTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBackingData:(GameResultDetailsAttributes *)backingData
{
    _backingData = backingData;

    FlashSetItemAttributes* setItem = [[FlashSetLogic singleton] getSetItemForId:backingData.flashCardId];
    
    [self.setTerm setText:setItem.term];
    [self.numOfCorrectAnswers setText:[backingData.correctGuesses stringValue]];
    [self.totalGuessesLabel setText:[backingData.totalGuesses stringValue]];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
