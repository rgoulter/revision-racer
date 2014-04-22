//
//  GameResultsViewController.m
//  RacerGame
//
//  Created by Richard Goulter on 31/3/14.
//  Copyright (c) 2014 Hunar Khanna. All rights reserved.
//

#import "GameResultsViewController.h"
#import "GameResultTableCell.h"

@interface GameResultsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *statisticsTable;

@property (strong, nonatomic) NSArray* listOfResultsDetails;
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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.statisticsTable.separatorColor = [UIColor lightGrayColor];
    self.statisticsTable.dataSource = self;
    // Do any additional setup after loading the view.
    
    //Register custom table view cell
    UINib* customCellNib = [UINib nibWithNibName:@"GameResultTableCell" bundle:[NSBundle mainBundle]];
    [self.statisticsTable registerNib:customCellNib forCellReuseIdentifier:@"GameResultCell"];
    
    GameResultTableCell* tableCell = [[[NSBundle mainBundle] loadNibNamed:@"GameResultTableCell" owner:nil options:nil] lastObject];
    self.statisticsTable.rowHeight = tableCell.bounds.size.height;

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
@end
