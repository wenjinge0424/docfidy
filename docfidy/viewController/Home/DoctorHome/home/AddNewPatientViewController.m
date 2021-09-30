//
//  AddNewPatientViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AddNewPatientViewController.h"
#import "CustomTableViewCell.h"
#import "SelectStringViewController.h"
#import "SelectDoctorViewController.h"

@interface AddNewPatientViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectStringViewControllerDelegate, SelectDoctorViewControllerDelegate, UITextFieldDelegate>
{
    PFObject * patientObj;
    
    NSMutableArray * doctors;
    NSMutableArray * codeList;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_add;

@end

@implementation AddNewPatientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    patientObj = [PFObject objectWithClassName:PARSE_TABLE_PATIENTS];
    doctors = [NSMutableArray new];
    codeList = [NSMutableArray new];
    [doctors addObject:@""];
    [codeList addObject:@""];
    if(self.runType == APP_RUN_MODE_ADD){
        self.lbl_title.text = @"New Patient";
        [self.btn_add setTitle:@"Add" forState:UIControlStateNormal];
        self.currentPatient = [PFObject objectWithClassName:PARSE_TABLE_PATIENTS];
        if(!doctors || doctors.count == 0){ doctors = [NSMutableArray new]; [doctors addObject:@""];}
        if(!codeList || codeList.count == 0){ codeList = [NSMutableArray new]; [codeList addObject:@""];}
    }else{
        self.lbl_title.text = @"Edit Patient Information";
        [self.btn_add setTitle:@"Save" forState:UIControlStateNormal];
        doctors = self.currentPatient[PARSE_PATIENTS_DOCTOR];
        codeList = self.currentPatient[PARSE_PATIENTS_DIAGNOSISCODE];
        if(!doctors || doctors.count == 0){ doctors = [NSMutableArray new]; [doctors addObject:@""];}
        if(!codeList || codeList.count == 0){ codeList = [NSMutableArray new]; [codeList addObject:@""];}
    }
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([AppStateManager sharedInstance].doctorArray.count == 0){
        [self showLoadingBar];
        NSMutableArray * doctorArray = [NSMutableArray new];
        PFQuery * doctorquery = [PFUser query];
        [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
        [self hideLoadingBar];
        [doctorquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
            if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            } else {
                for (int i=0;i<array.count;i++){
                    PFUser *owner = [array objectAtIndex:i];
                    [doctorArray addObject:owner];
                }
                [[AppStateManager sharedInstance] setDoctorArray:doctorArray];
                [self reloadData];
            }
        }];
    }else{
        [self reloadData];
    }
}
- (void) reloadData
{
    self.tbl_data.delegate = self;
    self.tbl_data.dataSource = self;
    [self.tbl_data reloadData];
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
    if(!self.currentPatient[PARSE_PATIENTS_FIRSTNAME] || [self.currentPatient[PARSE_PATIENTS_FIRSTNAME] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter first name."];
        return;
    }
    if(!self.currentPatient[PARSE_PATIENTS_LASTNAME] || [self.currentPatient[PARSE_PATIENTS_LASTNAME] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter last name."];
        return;
    }
    if(!self.currentPatient[PARSE_PATIENTS_RECORDNUMBER] || [self.currentPatient[PARSE_PATIENTS_RECORDNUMBER] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter medical record number."];
        return;
    }
    if(!self.currentPatient[PARSE_PATIENTS_FINALNUMBER] || [self.currentPatient[PARSE_PATIENTS_FINALNUMBER] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter financial identification number."];
        return;
    }
    if(!self.currentPatient[PARSE_PATIENTS_MEDICALINSURANCE] || [self.currentPatient[PARSE_PATIENTS_MEDICALINSURANCE] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please select medical insurance."];
        return;
    }
    if(!self.currentPatient[PARSE_PATIENTS_BIRTH] || [self.currentPatient[PARSE_PATIENTS_BIRTH] isKindOfClass:[NSNull class]]){
        [Util showAlertTitle:self title:@"Error" message:@"Please select date of birth."];
        return;
    }
    NSString * lastcode = [codeList lastObject];
    if([lastcode isEqualToString:@""]){
        [codeList removeLastObject];
    }
    if(codeList.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select diagnosis code."];
        [codeList addObject:@""];
        return;
    }
    NSObject * lastDoctor = [doctors lastObject];
    if([lastDoctor isKindOfClass:[NSString class]]){
        [doctors removeLastObject];
    }
    if(doctors.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select doctor."];
        [doctors addObject:@""];
        return;
    }
    if(self.runType == APP_RUN_MODE_ADD){
//        self.currentPatient = [PFObject objectWithClassName:PARSE_TABLE_PATIENTS];
        self.currentPatient[PARSE_PATIENTS_OWNER] = [PFUser currentUser];
        self.currentPatient[PARSE_PATIENTS_STATE] = [NSNumber numberWithInt:0];
    }else{
    }
    self.currentPatient[PARSE_PATIENTS_DIAGNOSISCODE] = codeList;
    self.currentPatient[PARSE_PATIENTS_DOCTOR] = doctors;
    self.currentPatient[PARSE_PATIENTS_CURRENTDOCTOR] = [doctors firstObject];
//    self.currentPatient[PARSE_PATIENTS_FIRSTNAME] = [self getDataWithTag:0];
//    self.currentPatient[PARSE_PATIENTS_LASTNAME] = [self getDataWithTag:1];
//    self.currentPatient[PARSE_PATIENTS_RECORDNUMBER] = [self getDataWithTag:2];
//    self.currentPatient[PARSE_PATIENTS_FINALNUMBER] = [self getDataWithTag:3];
//    self.currentPatient[PARSE_PATIENTS_MEDICALINSURANCE] = [self getDataWithTag:4];
//    self.currentPatient[PARSE_PATIENTS_BIRTH] = [self getDataWithTag:5];
    
    
    [self showLoadingBar];
    [self.currentPatient saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self hideLoadingBar];
        if(!succeeded){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }else{
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8 + doctors.count + codeList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < 6){
        static NSString *cellIdentifier = @"TextEditCell";
        TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.edt_text.tag = indexPath.row;
            if(indexPath.row == 0){// first name
                [self setTextFieldPlaceHolder:@"First Name" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = YES;
                cell.edt_text.text = [self getDataWithTag:(int)indexPath.row];
            }else if(indexPath.row == 1){// last name
                [self setTextFieldPlaceHolder:@"Last Name" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = YES;
                cell.edt_text.text = [self getDataWithTag:(int)indexPath.row];
            }else if(indexPath.row == 2){// Medical Record number
                [self setTextFieldPlaceHolder:@"Medical Record Number" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeNumberPad];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = YES;
                cell.edt_text.text = [self getDataWithTag:(int)indexPath.row];
            }else if(indexPath.row == 3){// final id
                [self setTextFieldPlaceHolder:@"Financial Identification Number" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = YES;
                cell.edt_text.text = [self getDataWithTag:(int)indexPath.row];
            }else if(indexPath.row == 4){// medical insure
                [self setTextFieldPlaceHolder:@"Medical Insurance" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = NO;
                cell.edt_text.text = [self getDataWithTag:(int)indexPath.row];
                [cell.btn_action addTarget:self action:@selector(onSelectMedicalInsurance:) forControlEvents:UIControlEventTouchUpInside];
            }else if(indexPath.row == 5){// birth date
                [self setTextFieldPlaceHolder:@"Date of birth" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.delegate = self;
                cell.btn_action.hidden = NO;
                NSDate * birthDate = self.currentPatient[PARSE_PATIENTS_BIRTH];
                if(birthDate){
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
                    NSString *dateString = [dateFormatter stringFromDate:birthDate];
                    cell.edt_text.text = dateString;
                }
                [cell.btn_action addTarget:self action:@selector(onSelectBirthDate:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        return cell;
    }else{
        int currentIndex = (int)indexPath.row - 6;
        if(currentIndex < codeList.count){/// diagnoise code
            static NSString *cellIdentifier = @"TextEditCell";
            TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell){
                [self setTextFieldPlaceHolder:@"Diagnosis code" toTextField:cell.edt_text];
                [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                cell.edt_text.text = [codeList objectAtIndex:currentIndex];
                cell.btn_action.tag = currentIndex;
                cell.btn_action.hidden = NO;
                [cell.btn_action removeTarget:self action:@selector(onSelectDoctor:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_action addTarget:self action:@selector(onSelectDiagnosisCode:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }else if(currentIndex == codeList.count){
            static NSString *cellIdentifier = @"RightCornerButtonCell";
            RightCornerButtonCell *cell = (RightCornerButtonCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell){
                cell.btn_action.tag = 1;
                [cell.btn_action addTarget:self action:@selector(onAddMoreDiagnosisCode:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }else{/// doctors
            currentIndex = (int)indexPath.row - 6 - (int)codeList.count - 1;
            if(currentIndex < doctors.count){
                static NSString *cellIdentifier = @"TextEditCell";
                TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell){
                    [self setTextFieldPlaceHolder:@"Doctor" toTextField:cell.edt_text];
                    [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
                    NSObject * currentDoct = [doctors objectAtIndex:currentIndex];
                    if([currentDoct isKindOfClass:[PFUser class]]){
                        PFUser * doctor = (PFUser*)currentDoct;
                        cell.edt_text.text = [NSString stringWithFormat:@"%@ %@", doctor[PARSE_USER_FIRSTNAME], doctor[PARSE_USER_LASTSTNAME]];
                    }else{
                        cell.edt_text.text = @"";
                    }
                    cell.btn_action.tag = currentIndex;
                    cell.btn_action.hidden = NO;
                    [cell.btn_action removeTarget:self action:@selector(onSelectDiagnosisCode:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.btn_action addTarget:self action:@selector(onSelectDoctor:) forControlEvents:UIControlEventTouchUpInside];
                }
                return cell;
            }else{
                static NSString *cellIdentifier = @"RightCornerButtonCell";
                RightCornerButtonCell *cell = (RightCornerButtonCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
                if(cell){
                    cell.btn_action.tag = 2;
                    [cell.btn_action addTarget:self action:@selector(onAddMoreDoctor:) forControlEvents:UIControlEventTouchUpInside];
                }
                return cell;
            }
        }
    }
    return nil;
}

- (void) setTextFieldPlaceHolder:(NSString*) str toTextField:(UITextField*) view
{
    view.placeholder = str;
    view.attributedPlaceholder = [[NSAttributedString alloc] initWithString:view.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}


- (void) onSelectMedicalInsurance:(UIButton*)button
{
    SelectStringViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectStringViewController"];
    controller.stringArray = MEDICAL_INSURANCE;
    controller.ctrolIndex = 0;
    controller.delegate = self;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void)stringSelected:(NSString *)str withTag:(int)tag
{
    if(tag == 0){///MEDICAL_INSURANCE
        self.currentPatient[PARSE_PATIENTS_MEDICALINSURANCE] = str;
        [self reloadData];
    }else if(tag < 1000){//DIAGNOSISCODE
        int buttonIndex = tag - 100;
        if(codeList.count <= buttonIndex)
            return;
        [codeList replaceObjectAtIndex:buttonIndex withObject:str];
        [self reloadData];
    }
}

- (void) onSelectBirthDate:(UIButton*)button
{
    __weak AddNewPatientViewController *weakSelf = self;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *date = [NSDate date];//[dateFormatter dateFromString:[NSDate date]];
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:date selectedBlock:^(NSDate *selectedDate) {
        __strong AddNewPatientViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        self.currentPatient[PARSE_PATIENTS_BIRTH] = selectedDate;
        [self reloadData];
    } cancelBlock:^{
        __strong AddNewPatientViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}
- (void) onSelectDiagnosisCode:(UIButton*)button
{
    SelectStringViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectStringViewController"];
    controller.stringArray = [[CSVUtil new] getDiagnosisCodes];;
    controller.ExceptionArray = codeList;
    controller.ctrolIndex = (int)button.tag + 100;
    controller.delegate = self;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void) onSelectDoctor:(UIButton*)button
{
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = [AppStateManager sharedInstance].doctorArray;
    controller.ExceptionArray = doctors;
    controller.needAnyDoctor = YES;
    controller.delegate = self;
    controller.ctrlIndex = (int)button.tag;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void) doctorSelected:(PFUser *)user withTag:(int)index
{
    if(doctors.count <= index)
        return;
    [doctors replaceObjectAtIndex:index withObject:user];
    [self reloadData];
}
- (void) onAddMoreDiagnosisCode:(UIButton*)button
{
    NSString * lastItem = [codeList lastObject];
    if([lastItem isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter diagnosis code."];
//        [self reloadData];
        return;
    }
    [codeList addObject:@""];
    [self reloadData];
}
- (void) onAddMoreDoctor:(UIButton*)button
{
    NSObject * lastItem = [doctors lastObject];
    if(![lastItem isKindOfClass:[PFUser class]]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter doctor."];
//        [self reloadData];
        return;
    }
    [doctors addObject:@""];
    [self reloadData];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self setDataWithTag:(int)textField.tag withData:textField.text];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"];
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c])
        {
            return NO;
        }
    }
    return YES;
}

- (void) setDataWithTag:(int)tag withData:(NSString*)data
{
    if(tag == 0){// first name
        self.currentPatient[PARSE_PATIENTS_FIRSTNAME] = data;
    }else if(tag == 1){// last name
        self.currentPatient[PARSE_PATIENTS_LASTNAME] = data;
    }else if(tag == 2){// Medical Record number
        self.currentPatient[PARSE_PATIENTS_RECORDNUMBER] = data;
    }else if(tag == 3){// final id
        self.currentPatient[PARSE_PATIENTS_FINALNUMBER] = data;
    }
}
- (NSString*) getDataWithTag:(int)tag
{
    if(tag == 0){// first name
        return self.currentPatient[PARSE_PATIENTS_FIRSTNAME];
    }else if(tag == 1){// last name
        return self.currentPatient[PARSE_PATIENTS_LASTNAME];
    }else if(tag == 2){// Medical Record number
        return self.currentPatient[PARSE_PATIENTS_RECORDNUMBER];
    }else if(tag == 3){// final id
        return self.currentPatient[PARSE_PATIENTS_FINALNUMBER];
    }else if(tag == 4){// medical insure
        return self.currentPatient[PARSE_PATIENTS_MEDICALINSURANCE];
    }else if(tag == 5){// birth date
        return self.currentPatient[PARSE_PATIENTS_BIRTH];
    }
    return @"";
}
@end
