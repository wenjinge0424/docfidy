//
//  AdminPatientsListViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminPatientsListViewController.h"
#import "TitleTableViewCell.h"
#import "PatientDetailViewController.h"
#import "NewPatientViewController.h"
#import "AddNewPatientViewController.h"

@interface AdminPatientsListViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    int runType;
    NSMutableArray * dataArray;
    NSMutableArray * searchedArray;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_new;
@property (weak, nonatomic) IBOutlet UIButton *btn_current;
@property (weak, nonatomic) IBOutlet UIButton *btn_discharge;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UITextField *edt_search;

@end

@implementation AdminPatientsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    runType = 0;
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_search.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData:runType];
}
- (void) fetchData:(int)type
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    
    dataArray = [[NSMutableArray alloc] init];
    
    
    PFQuery * doctorquery = [PFUser query];
    [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    PFQuery * nursequery = [PFUser query];
    [nursequery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
    PFQuery * userQuery = [PFQuery orQueryWithSubqueries:@[doctorquery, nursequery]];
    [self showLoadingBar];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            NSMutableArray * doctorArray = [NSMutableArray new];
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [doctorArray addObject:owner];
            }
            [[AppStateManager sharedInstance] setDoctorArray:doctorArray];
            
            PFQuery * query  = [PFQuery queryWithClassName:PARSE_TABLE_PATIENTS];
            [query includeKey:PARSE_PATIENTS_DOCTOR];
            [query includeKey:PARSE_PATIENTS_NURSE];
            [query includeKey:PARSE_PATIENTS_CURRENTDOCTOR];
            [query includeKey:PARSE_PATIENTS_CURRENTNURSE];
            [query orderByDescending:PARSE_FIELD_UPDATED_AT];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [self hideLoadingBar];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFObject  *owner = [array objectAtIndex:i];
                        [dataArray addObject:owner];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableForSearchKey:self.edt_search.text];
                    });
                }
            }];
        }
    }];
 }
- (BOOL) isTypeOfPatient:(int)type at:(PFObject*)patient
{
    int number = [patient[PARSE_PATIENTS_STATE] intValue];
    NSArray * billingArray = patient[PARSE_PATIENTS_BILLING];
    if(billingArray && billingArray.count > 0){
        if(type == 0){// new
            return NO;
        }else if(type == 2){// current
            return YES;
        }
    }else{
        if(type == 0){// new
            return YES;
        }else if(type == 2){// current
            return NO;
        }
    }
    if(number == 2){/// discharged
        if(type == 1){
            return YES;
        }
    }
    return NO;
}
- (void) reloadTableForSearchKey:(NSString*)searchKey
{
    searchedArray = [NSMutableArray new];
    for(PFObject * patientObj in dataArray){
        if([searchKey isEqualToString:@""]){
            if([self isTypeOfPatient:runType at:patientObj])
                [searchedArray addObject:patientObj];
        }else{
            if([self searchPatientWithKey:searchKey atPatient:patientObj]){
                if([self isTypeOfPatient:runType at:patientObj])
                    [searchedArray addObject:patientObj];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource  = self;
        [self.tbl_data reloadData];
    });
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadTableForSearchKey:searchStr];
    return YES;
}
- (BOOL) searchPatientWithKey:(NSString*)key atPatient:(PFObject*)patient
{
    if(key.length == 0)
        return YES;
    NSString * patientName = [NSString stringWithFormat:@"%@ %@", patient[PARSE_PATIENTS_FIRSTNAME], patient[PARSE_PATIENTS_LASTNAME]];
    if([Util stringIsMatched:patientName searchKey:key])
        return YES;
    return NO;
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
- (IBAction)onAdd:(id)sender {
    AddNewPatientViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddNewPatientViewController"];
    controller.runType = APP_RUN_MODE_ADD;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onNew:(id)sender {
    self.btn_new.selected = YES;
    self.btn_current.selected = NO;
    self.btn_discharge.selected = NO;
    runType = 0;
    [self fetchData:runType];
}
- (IBAction)onCurrent:(id)sender {
    self.btn_new.selected = NO;
    self.btn_current.selected = YES;
    self.btn_discharge.selected = NO;
    runType = 2;
    [self fetchData:runType];
}
- (IBAction)onDischarge:(id)sender {
    self.btn_new.selected = NO;
    self.btn_current.selected = NO;
    self.btn_discharge.selected = YES;
    runType = 1;
    [self fetchData:runType];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFObject * currentUser = [searchedArray objectAtIndex:indexPath.row];
        cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", currentUser[PARSE_PATIENTS_FIRSTNAME], currentUser[PARSE_PATIENTS_LASTNAME]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject * currentPatient = [searchedArray objectAtIndex:indexPath.row];
    
    PatientDetailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PatientDetailViewController"];
    controller.patientObj = currentPatient;
    controller.runType = runType;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
