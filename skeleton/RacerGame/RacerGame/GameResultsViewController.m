//
//  GameResultsViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultsViewController.h"
#import "GameResultTableCell.h"
#import "GameResultInfoAttributes.h"
#import "FlashSetLogic.h"
#import "NavigationButton.h"
#import "StyleManager.h"

@interface GameResultsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *statisticsTable;

@property (strong, nonatomic) NSArray* listOfResultsDetails;
@property (strong, nonatomic) GameResultInfoAttributes* resultSummary;
@property (strong, nonatomic) IBOutlet NavigationButton* mainMenuNavButton;

//Labels
@property (strong, nonatomic) IBOutlet UILabel *setNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *accuracyLabel;

@end

@implementation GameResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Reset values
    self.listOfResultsDetails = self.listOfResultsDetails;
    self.resultSummary = self.resultSummary;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.statisticsTable.separatorColor = [UIColor lightGrayColor];
    self.statisticsTable.dataSource = self;
    // Do any additional setup after loading the view.
    
    //Register custom table view cell
    UINib* customCellNib = [UINib nibWithNibName:@"GameResultTableCell" bundle:[NSBundle mainBundle]];
    [self.statisticsTable registerNib:customCellNib forCellReuseIdentifier:@"GameResultCell"];
    
    GameResultTableCell* tableCell = [[[NSBundle mainBundle] loadNibNamed:@"GameResultTableCell" owner:nil options:nil] lastObject];
    self.statisticsTable.rowHeight = tableCell.bounds.size.height;
    
    //Set main menu button text
    StyleManager* manager = [StyleManager manager];
    [self.mainMenuNavButton setAttributedTitle:[manager getAttributedButtonTextForString:@"Main Menu"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)mainMenuBtnPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Public methods
-(void)setSummaryOfResults:(GameResultInfoAttributes *)summary withDetails:(NSArray *)details
{
    self.resultSummary = summary;
    self.listOfResultsDetails = details;
}

#pragma mark UITableViewDataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* dequeuedCell = [tableView dequeueReusableCellWithIdentifier:@"GameResultCell"];
    GameResultTableCell* customCell = (GameResultTableCell*)dequeuedCell;
    
    GameResultDetailsAttributes* currentDetails = self.listOfResultsDetails[[indexPath item]];
    [customCell setBackingData:currentDetails];
    return customCell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listOfResultsDetails count];
}

#pragma mark Setters
-(void)setResultSummary:(GameResultInfoAttributes *)resultSummary
{
    _resultSummary = resultSummary;
    
    NSString* score = [resultSummary.score stringValue];
    NSLog(@"User score: %@",score);
    [self.gameScoreLabel setText:score];
    
    FlashSetInfoAttributes* playedSet = [[FlashSetLogic singleton] getSetForId:resultSummary.setId];
    NSString* nameOfSet = playedSet.title;
    NSLog(@"Set name : %@",nameOfSet);
    [self.setNameLabel setText:nameOfSet];
}

-(void)setListOfResultsDetails:(NSArray *)listOfResultsDetails
{
    _listOfResultsDetails = listOfResultsDetails;
    
    NSInteger totalGuesses = 0;
    NSInteger correctGuesses = 0;
    
    for (GameResultDetailsAttributes* eachTerm in self.listOfResultsDetails) {
        totalGuesses = totalGuesses + [eachTerm.totalGuesses integerValue];
        correctGuesses = correctGuesses + [eachTerm.correctGuesses integerValue];
    }
    
    [self.accuracyLabel setText:[NSString stringWithFormat:@"%@ out of %@",@(correctGuesses),@(totalGuesses)]];
}
@end
