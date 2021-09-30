//
//  AdminScheduleListViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminScheduleListViewController.h"
#import "ScheuleListTableViewCell.h"
#import "AdminDailyScheduleViewController.h"

@interface AdminScheduleListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSDate * selectedDate;
    
    NSMutableArray * scheduleDatas;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateStr;
@end

@implementation AdminScheduleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedDate = [NSDate date];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData:selectedDate];
}
- (void) fetchData:(NSDate* )date
{
    self.lbl_dateStr.text = [Util convertDateToString:date];
    scheduleDatas = [NSMutableArray new];
    [self showLoadingBar];
    NSMutableArray * startEndTime = [Util getDateStartAndEnd:date];
    PFQuery * query  = [PFQuery queryWithClassName:PARSE_TABLE_SCHEDULE];
//    if(self.runTypeDoctor){
//        [query whereKey:PARSE_SCHEDULE_OWNER equalTo:[PFUser currentUser]];
//    }
    [query whereKey:PARSE_SCHEDULE_STARTTIME greaterThan:[startEndTime firstObject]];
    [query whereKey:PARSE_SCHEDULE_ENDTIME lessThan:[startEndTime lastObject]];
    [query includeKey:PARSE_SCHEDULE_OWNER];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFObject * owner = [array objectAtIndex:i];
                [scheduleDatas addObject:owner];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tbl_data.delegate = self;
                self.tbl_data.dataSource = self;
                [self.tbl_data reloadData];
            });
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onBeforeDate:(id)sender {
    selectedDate = [Util yesterday:selectedDate];
    [self fetchData:selectedDate];
}
- (IBAction)onNextDate:(id)sender {
    selectedDate = [Util tomorrow:selectedDate];
    [self fetchData:selectedDate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return scheduleDatas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ScheuleListTableViewCell";
    ScheuleListTableViewCell *cell = (ScheuleListTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.view_gray.layer.cornerRadius = 5.f;
        cell.view_darkgray.layer.cornerRadius = 5.f;
        PFObject * currentSchedule = [scheduleDatas objectAtIndex:indexPath.row];
        PFUser * currentUser = currentSchedule[PARSE_SCHEDULE_OWNER];
        NSString * fullName = [NSString stringWithFormat:@"Dr. %@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
        cell.lbl_title.text = fullName;
        cell.lbl_detail.text = [NSString stringWithFormat:@"Floor number: %@", currentSchedule[PARSE_SCHEDULE_FLOORWOARD]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end
