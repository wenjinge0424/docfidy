//
//  AdminAddScheduleViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminAddScheduleViewController.h"
#import "SelectDoctorViewController.h"


@interface AdminAddScheduleViewController ()<UITableViewDelegate, UITableViewDataSource, SelectDoctorViewControllerDelegate>
{
    NSDate * m_selectedDate;
    NSDate * m_selectedStartTime;
    NSDate * m_selectedEndTime;
    PFUser * m_selectedDoctor;
    
    NSMutableArray * dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_date;
@property (weak, nonatomic) IBOutlet UITextField *edt_startTime;
@property (weak, nonatomic) IBOutlet UITextField *edt_endTime;
@property (weak, nonatomic) IBOutlet UITextField *edt_doctor;
@property (weak, nonatomic) IBOutlet UITextField *edt_floor;

@end

@implementation AdminAddScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_date.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_date.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_startTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_startTime.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_endTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_endTime.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_doctor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_doctor.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_floor.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_floor.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    [self.edt_date setText:[dateFormatter stringFromDate:[NSDate date]]];
    m_selectedDate = [NSDate date];
    
    PFUser * me = [PFUser currentUser];
    if([me[PARSE_USER_TYPE] intValue] == 200){
        self.runTypeDoctor = YES;
    }
    
    if(self.runTypeDoctor){
        m_selectedDoctor = [PFUser currentUser];
        self.edt_doctor.text = [NSString stringWithFormat:@"Dr. %@ %@", m_selectedDoctor[PARSE_USER_FIRSTNAME], m_selectedDoctor[PARSE_USER_LASTSTNAME]];
        self.edt_doctor.userInteractionEnabled = NO;
    }else{
        self.edt_doctor.userInteractionEnabled = YES;
        [self fetchData];
    }
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [self showLoadingBar];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
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
- (IBAction)onSave:(id)sender {
    if(self.edt_date.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter date."];
        return;
    }
    if(self.edt_startTime.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter start time."];
        return;
    }
    if(self.edt_endTime.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter end time."];
        return;
    }
    if(self.edt_doctor.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter doctor name."];
        return;
    }
    if(self.edt_floor.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter floor/ward."];
        return;
    }
    NSDate * startTime = [Util getFullDateFrom:m_selectedDate withTime:m_selectedStartTime];
    NSDate * endTime = [Util getFullDateFrom:m_selectedDate withTime:m_selectedEndTime];
    PFObject * object = [PFObject objectWithClassName:PARSE_TABLE_SCHEDULE];
    object[PARSE_SCHEDULE_STARTTIME] = startTime;
    object[PARSE_SCHEDULE_ENDTIME] = endTime;
    object[PARSE_SCHEDULE_OWNER] = m_selectedDoctor;
    object[PARSE_SCHEDULE_FLOORWOARD] = self.edt_floor.text;
    [self showLoadingBar];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
    
}

- (IBAction)onSelectDate:(id)sender {
    __weak AdminAddScheduleViewController *weakSelf = self;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *date = [NSDate date];//[dateFormatter dateFromString:[NSDate date]];
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        m_selectedDate = selectedDate;
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        NSString *dateString = [dateFormatter stringFromDate:selectedDate];
        [self.edt_date setText:dateString];
    } cancelBlock:^{
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
- (IBAction)onSelectStartTime:(id)sender {
    __weak AdminAddScheduleViewController *weakSelf = self;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *date = [NSDate date];//[dateFormatter dateFromString:[NSDate date]];
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithTime:date selectedBlock:^(NSDate *selectedDate) {
        m_selectedStartTime = selectedDate;
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        NSString *dateString = [dateFormatter stringFromDate:selectedDate];
        [self.edt_startTime setText:dateString];
    } cancelBlock:^{
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
- (IBAction)onSelectEndTime:(id)sender {
    __weak AdminAddScheduleViewController *weakSelf = self;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSDate *date = [NSDate date];//[dateFormatter dateFromString:[NSDate date]];
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithTime:date selectedBlock:^(NSDate *selectedDate) {
        m_selectedEndTime = selectedDate;
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        NSString *dateString = [dateFormatter stringFromDate:selectedDate];
        [self.edt_endTime setText:dateString];
    } cancelBlock:^{
        __strong AdminAddScheduleViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
- (IBAction)onSelectDoctor:(id)sender {
    if(self.runTypeDoctor){
        return;
    }
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = dataArray;
    controller.delegate = self;
    controller.ctrlIndex = 0;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void) doctorSelected:(PFUser *)user withTag:(int)index
{
    m_selectedDoctor = user;
    NSString * fullName = [NSString stringWithFormat:@"Dr. %@ %@", m_selectedDoctor[PARSE_USER_FIRSTNAME], m_selectedDoctor[PARSE_USER_LASTSTNAME]];
    self.edt_doctor.text = fullName;
}
@end
