//
//  AdminDailyScheduleViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminDailyScheduleViewController.h"
#import <JTCalendar/JTCalendar.h>
#import "ScheduleGraphTableViewCell.h"
#import "AdminAddScheduleViewController.h"

@interface AdminDailyScheduleViewController ()<JTCalendarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSDate *_todayDate;
    NSDate *_minDate;
    NSDate *_maxDate;
    NSDate *_dateSelected;
    
    NSMutableArray * scheduleDatas;
    NSMutableArray * scheduleDicts;
}
@property (weak, nonatomic) IBOutlet UIView *view_calendarContainer;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UIView *view_addBtn;
@end

@implementation AdminDailyScheduleViewController
- (void)createMinAndMaxDate
{
    _todayDate = [NSDate date];
    
    _maxDate = [_calendarManager.dateHelper addToDate:_todayDate months:12];
    _minDate = [_calendarManager.dateHelper addToDate:_todayDate months:-12];
    
    PFUser * me = [PFUser currentUser];
    int userType = [me[PARSE_USER_TYPE] intValue];
    if(userType == 100 || userType == 300){
        [self.view_addBtn setHidden:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dateSelected = self.selectedDate;
    
    _calendarManager = [JTCalendarManager new];
    [self createMinAndMaxDate];
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:_todayDate];
    _calendarManager.settings.weekModeEnabled = YES;
    _calendarManager.delegate = self;
    [_calendarManager setDate:_dateSelected];
    [_calendarManager reload];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchData];
}
- (void) fetchData
{
    scheduleDatas = [NSMutableArray new];
    [self showLoadingBar];
    NSMutableArray * startEndTime = [Util getDateStartAndEnd:_dateSelected];
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
            
            [self configScheduleData];
        }
    }];
    
}
- (void) configScheduleData
{
    scheduleDicts = [NSMutableArray new];
    for(int i = 0; i<= 24;i++){
        int startHour = i;
        int endHour = i+1;
        [scheduleDicts addObject:[NSString stringWithFormat:@"%02d:00", i]];
        for(PFObject * scheduleObj in scheduleDatas){
            NSDate * startTime = scheduleObj[PARSE_SCHEDULE_STARTTIME];
            NSDate * endTime = scheduleObj[PARSE_SCHEDULE_ENDTIME];
            int u_startHour = [Util getHour:startTime];
            int u_endHour = [Util getHour:endTime];
            if(u_startHour <= startHour && u_endHour >= endHour-1){
                [scheduleDicts addObject:scheduleObj];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource = self;
        [self.tbl_data reloadData];
    });
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
- (IBAction)onAddNewe:(id)sender {
    AdminAddScheduleViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminAddScheduleViewController"];
    controller.runTypeDoctor = self.runTypeDoctor;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return scheduleDicts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject * currentObj = [scheduleDicts objectAtIndex:indexPath.row];
    if([currentObj isKindOfClass:[NSString class]]){
        static NSString *cellIdentifier = @"ScheduleGraphLineTableViewCell";
        ScheduleGraphLineTableViewCell *cell = (ScheduleGraphLineTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_time.text = (NSString*)currentObj;
            if(scheduleDicts.count > indexPath.row + 1){
                NSObject * scheduleObj = [scheduleDicts objectAtIndex:indexPath.row + 1];
                if([scheduleObj isKindOfClass:[PFObject class]]){
                    [cell.lbl_time setTextColor:[UIColor redColor]];
                    [cell.lbl_rect setHidden:NO];
                    [cell.lbl_line setBackgroundColor:[UIColor redColor]];
                }else{
                    [cell.lbl_time setTextColor:[UIColor blackColor]];
                    [cell.lbl_rect setHidden:YES];
                    [cell.lbl_line setBackgroundColor:[UIColor blackColor]];
                }
            }else{
                [cell.lbl_time setTextColor:[UIColor blackColor]];
                [cell.lbl_rect setHidden:YES];
                [cell.lbl_line setBackgroundColor:[UIColor blackColor]];
            }
        }
        return cell;
    }else{
        PFObject * scheduleObj = (PFObject*)currentObj;
        static NSString *cellIdentifier = @"ScheduleGraphDetailTableViewCell";
        ScheduleGraphDetailTableViewCell *cell = (ScheduleGraphDetailTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            PFUser * owner = scheduleObj[PARSE_SCHEDULE_OWNER];
            NSString * str = [NSString stringWithFormat:@"Dr. %@ %@ %@", owner[PARSE_USER_FIRSTNAME], owner[PARSE_USER_LASTSTNAME], scheduleObj[PARSE_SCHEDULE_FLOORWOARD]];
            cell.lbl_title.text = str;
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithRed:53/255.f green:114/255.f blue:244/255.f alpha:1.f];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:232/255.f green:181/255.f blue:98/255.f alpha:1.f];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor colorWithRed:232/255.f green:181/255.f blue:98/255.f alpha:1.f];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    //    if([self dateHaveEvent:dayView.date]){
    //        dayView.dotView.hidden = NO;
    //    }
    //    else{
    dayView.dotView.hidden = YES;
    //    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _dateSelected = dayView.date;
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    if([_calendarManager.dateHelper date:_dateSelected isEqualOrAfter:_minDate andEqualOrBefore:_maxDate]){
        [self fetchData];
        
    }
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
}
#pragma mark - CalendarManager delegate - Page mangement
// Used to limit the date for the calendar, optional
- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date{
    return [_calendarManager.dateHelper date:date isEqualOrAfter:_minDate andEqualOrBefore:_maxDate];
}
- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar{}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar{}
@end
