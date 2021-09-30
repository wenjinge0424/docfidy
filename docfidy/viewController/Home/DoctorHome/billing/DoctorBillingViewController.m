//
//  DoctorBillingViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorBillingViewController.h"
#import "DoctorHomeTableViewCell.h"
#import "SelectDateViewController.h"
#import "DoctorMacrocodeViewController.h"
#import "EditBillingViewController.h"
#import "SelectStringViewController.h"
#import "CSVUtil.h"

@interface DoctorBillingViewController ()<UITableViewDelegate, UITableViewDataSource, SelectDateViewControllerDelegate, SelectStringViewControllerDelegate, UITextFieldDelegate>
{
    NSDate * selectedDate;
    int selectedRowIndex;
    NSMutableArray * showData;
    NSMutableArray * searchData;
    NSMutableDictionary * billingDict;
    
    PFObject * currentPatientObj;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateStr;
@property (weak, nonatomic) IBOutlet UITextField *edt_search;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@end

@implementation DoctorBillingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedDate = [NSDate date];
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    selectedRowIndex = -1;
    self.edt_search.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData:selectedDate];
}
- (void) fetchData:(NSDate* )date
{
    showData = [NSMutableArray new];
    billingDict = [NSMutableDictionary new];
    [self showLoadingBar];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_BILLING];
    [query whereKey:PARSE_BILLING_PAYMENTCOMPLETE notEqualTo:[NSNumber numberWithBool:YES]];
    [query includeKey:PARSE_BILLING_PATIENT];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for(PFObject * object in objects){
                PFObject * patientObj = object[PARSE_BILLING_PATIENT];
                NSDate * billingDate = object[PARSE_FIELD_UPDATED_AT];
                NSMutableArray * billingArray = [billingDict objectForKey:patientObj.objectId];
                if(!billingArray){
                    billingArray = [NSMutableArray new];
                    [showData addObject:patientObj];
                }
                if([[NSCalendar currentCalendar] isDateInToday:billingDate]){
                    [billingArray addObject:object];
                }
                [billingDict setObject:billingArray forKey:patientObj.objectId];
            }
            [self hideLoadingBar];
            self.lbl_dateStr.text = [Util convertDateToString:date];
            [self searchResult:[self.edt_search text]];
        }
    }];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self searchResult:searchStr];
    return YES;
}
- (void) searchResult:(NSString*)searchKey
{
    searchData = [NSMutableArray new];
    for(PFObject * patientObj in showData){
        NSString * name = [NSString stringWithFormat:@"%@ %@", patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]];
        NSString * recodeNum = patientObj[PARSE_PATIENTS_RECORDNUMBER];
        NSString * cptCode = patientObj[PARSE_PATIENTS_CPTCODE];
        if(searchKey.length == 0){
            [searchData addObject:patientObj];
        }else if([Util stringIsMatched:name searchKey:searchKey]){
            [searchData addObject:patientObj];
        }else if([Util stringIsMatched:recodeNum searchKey:searchKey]){
            [searchData addObject:patientObj];
        }else if([Util stringIsMatched:cptCode searchKey:searchKey]){
            [searchData addObject:patientObj];
        }else{
            NSMutableArray * biilingCodes = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
            BOOL isMatched = NO;
            for(NSString * billCode in biilingCodes){
                if([Util stringIsMatched:billCode searchKey:searchKey]){
                    isMatched = YES;
                }
            }
            if(isMatched){
                [searchData addObject:patientObj];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource  = self;
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
- (IBAction)onBeforeDate:(id)sender {
    selectedDate = [Util yesterday:selectedDate];
    [self fetchData:selectedDate];
}
- (IBAction)onNextDate:(id)sender {
    selectedDate = [Util tomorrow:selectedDate];
    [self fetchData:selectedDate];
}
- (IBAction)onMacrocode:(id)sender {
    DoctorMacrocodeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorMacrocodeViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSave:(id)sender {
}
- (IBAction)onCalendar:(id)sender {
    SelectDateViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDateViewController"];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void) SelectDateViewControllerDelegate_didSelectDate:(NSDate *)date
{
    selectedDate = date;
    [self fetchData:selectedDate];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tbl_data){
        return searchData.count;
    }
    PFObject * patientObj = [searchData objectAtIndex:tableView.tag];
    NSMutableArray * biilingCodes = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
    return biilingCodes.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tbl_data){
        if(selectedRowIndex == indexPath.row){
            PFObject * patientObj = [searchData objectAtIndex:indexPath.row];
            NSMutableArray * biilingCodes = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
            return 48 + biilingCodes.count * 34;
        }
        return 48;
    }
    return 34;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tbl_data){
        static NSString *cellIdentifier = @"DoctorBillingCell";
        DoctorBillingCell *cell = (DoctorBillingCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            PFObject * patientObj = [searchData objectAtIndex:indexPath.row];
            cell.mainContainer.layer.cornerRadius = 5.f;
            cell.view_color_container.layer.cornerRadius = 5.f;
            if(indexPath.row == selectedRowIndex){
                [cell.view_color_container setBackgroundColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]];
                cell.img_arrow_right.hidden = YES;
                cell.img_arrow_bottom.hidden = NO;
            }else{
                [cell.view_color_container setBackgroundColor:[UIColor clearColor]];
                cell.img_arrow_right.hidden = NO;
                cell.img_arrow_bottom.hidden = YES;
            }
            cell.btn_collapse.tag = indexPath.row;
            [cell.btn_collapse addTarget:self action:@selector(onCollape:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.lbl_number.text = patientObj[PARSE_PATIENTS_RECORDNUMBER];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]];
            NSMutableArray * billing = [billingDict objectForKey:patientObj.objectId];
            if(billing && billing.count > 0){
                PFObject * billObj = [billing firstObject];
                cell.lbl_value.text = billObj[PARSE_BILLING_CODE];
            }
            
            cell.btnCPTCode.layer.cornerRadius = 5.f;
            NSString * cptCode = patientObj[PARSE_PATIENTS_CPTCODE];
            if(!cptCode || cptCode.length == 0){
                [cell.btnCPTCode setTitle:@"Select CPT Code" forState:UIControlStateNormal];
            }else{
                [cell.btnCPTCode setTitle:cptCode forState:UIControlStateNormal];
            }
            cell.btnCPTCode.tag = indexPath.row;
            [cell.btnCPTCode addTarget:self action:@selector(onSelectCPTCode:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.view_table.tag = indexPath.row;
            [cell.view_table setDelegate:self];
            [cell.view_table setDataSource:self];
            [cell.view_table reloadData];
            [cell resizeNumberLabel];
        }
        return cell;
    }else{
        int tableIndex = (int)tableView.tag;
        PFObject * patientObj = [searchData objectAtIndex:tableIndex];
        NSMutableArray * biilingCodes = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
        NSString * currentCode = [biilingCodes objectAtIndex:indexPath.row];
        static NSString *cellIdentifier = @"DoctorHomeDoctorCell";
        DoctorHomeDoctorCell *cell = (DoctorHomeDoctorCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_title.text = currentCode;
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView == self.tbl_data){
        EditBillingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditBillingViewController"];
        PFObject * patientObj = [searchData objectAtIndex:indexPath.row];
        controller.patientObj = patientObj;
        NSMutableArray * billing = [billingDict objectForKey:patientObj.objectId];
        if(billing && billing.count > 0){
            PFObject * billObj = [billing firstObject];
            if(billObj)
                controller.billObject = billObj;
        }
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) onCollape:(UIButton*) button
{
    int index = (int)button.tag;
    if(selectedRowIndex == index){
        selectedRowIndex = -1;
    }else{
        selectedRowIndex = index;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource  = self;
        [self.tbl_data reloadData];
    });
}

- (void) onSelectCPTCode:(UIButton*)button
{
    CSVUtil * csvUtil = [CSVUtil new];
    PFObject * patientObj = [searchData objectAtIndex:button.tag];
    currentPatientObj = patientObj;
    SelectStringViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectStringViewController"];
    controller.stringArray = [csvUtil getCPTCodes];
    controller.ctrolIndex = 0;
    controller.delegate = self;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void)stringSelected:(NSString *)str withTag:(int)tag
{
    if(tag == 0){
        currentPatientObj[PARSE_PATIENTS_CPTCODE] = str;
        [self showLoadingBar];
        [currentPatientObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self hideLoadingBar];
            [self fetchData:selectedDate];
        }];
    }
}
@end
