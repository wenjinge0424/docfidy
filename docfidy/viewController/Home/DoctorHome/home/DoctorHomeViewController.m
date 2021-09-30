//
//  DoctorHomeViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorHomeViewController.h"
#import "DoctorHomeTableViewCell.h"
#import "AddNewPatientViewController.h"
#import "SelectDoctorViewController.h"
#import "DoctorBillingViewController.h"
#import "DoctorNoteListViewController.h"
#import "DoctorMainMenuViewController.h"
#import "PatientDetailViewController.h"
#import "MessageViewController.h"

@interface DoctorHomeViewController ()<UITableViewDelegate, UITableViewDataSource, SelectDoctorViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray * doctorArray;
    NSMutableArray * allPatients;
    int runType;
    
    NSMutableArray * originalArray;
    NSMutableArray * dataArray;
    
    NSMutableDictionary * dataDict;
    PFUser * me;
    
    int selectedSectionIndex;
    int selectedRowIndex;
    
    
    PFObject * selectedPatient;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_message_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_note_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_billing_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_macro_width;
@property (weak, nonatomic) IBOutlet UIView *view_macroTansfer;
@property (weak, nonatomic) IBOutlet UIView *view_billing;
@property (weak, nonatomic) IBOutlet UIView *view_notes;
@property (weak, nonatomic) IBOutlet UIView *view_messages;
@property (weak, nonatomic) IBOutlet UIButton *btn_currentPatient;
@property (weak, nonatomic) IBOutlet UIButton *btn_allpatients;
@property (weak, nonatomic) IBOutlet UIButton *btn_unseenPatients;
@property (weak, nonatomic) IBOutlet UIButton *btn_seenPatients;

@property (weak, nonatomic) IBOutlet UITextField *edt_search;
@property (weak, nonatomic) IBOutlet UITableView *tbl_date;
@end

@implementation DoctorHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    me = [PFUser currentUser];
    runType = 0;
    selectedRowIndex = -1;
    selectedSectionIndex = -1;
    self.edt_search.delegate = self;
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (void) fetchDoctors:(void (^)(NSMutableArray * array))completionBlock
{
    PFQuery * doctorquery = [PFUser query];
    [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    PFQuery * nursequery = [PFUser query];
    [nursequery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
    
    PFQuery * userQuery = [PFQuery orQueryWithSubqueries:@[doctorquery, nursequery]];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            completionBlock([NSMutableArray new]);
        } else {
            completionBlock([[NSMutableArray alloc] initWithArray:array]);
        }
    }];
}
- (void) fetchPatient:(void (^)(NSMutableArray * array))completionBlock
{
    PFQuery * query  = [PFQuery queryWithClassName:PARSE_TABLE_PATIENTS];
    [query includeKey:PARSE_PATIENTS_DOCTOR];
    [query includeKey:PARSE_PATIENTS_NURSE];
    [query includeKey:PARSE_PATIENTS_CURRENTDOCTOR];
    [query includeKey:PARSE_PATIENTS_CURRENTNURSE];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            completionBlock([NSMutableArray new]);
        } else {
            completionBlock([[NSMutableArray alloc] initWithArray:array]);
        }
    }];
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    originalArray = [[NSMutableArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    doctorArray = [[NSMutableArray alloc] init];
    allPatients = [NSMutableArray new];
    [self showLoadingBar];
    [self fetchDoctors:^(NSMutableArray *array) {
        for (int i=0;i<array.count;i++){
            PFUser *owner = [array objectAtIndex:i];
            [doctorArray addObject:owner];
        }
        [[AppStateManager sharedInstance] setDoctorArray:doctorArray];
        
        allPatients = [NSMutableArray new];
        [self fetchPatient:^(NSMutableArray *array) {
            for (int i=0;i<array.count;i++){
                PFObject  *owner = [array objectAtIndex:i];
                [allPatients addObject:owner];
            }
            [self hideLoadingBar];
            [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
        }];
    }];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadTableForIndex:runType withSearchKey:searchStr];
    return YES;
}
- (BOOL) searchPatientWithKey:(NSString*)key atPatient:(PFObject*)patient
{
    if(key.length == 0)
        return YES;
    NSString * patientName = [NSString stringWithFormat:@"%@ %@", patient[PARSE_PATIENTS_FIRSTNAME], patient[PARSE_PATIENTS_LASTNAME]];
    NSString * rocodeNum = patient[PARSE_PATIENTS_RECORDNUMBER];
    PFUser * currentDoctor = patient[PARSE_PATIENTS_CURRENTDOCTOR];
    NSString * currentDoctorName = [NSString stringWithFormat:@"%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]];
    if([Util stringIsMatched:patientName searchKey:key])
        return YES;
    if([Util stringIsMatched:rocodeNum searchKey:key])
        return YES;
    if([Util stringIsMatched:currentDoctorName searchKey:key])
        return YES;
    
    NSArray * doctors = patient[PARSE_PATIENTS_DOCTOR];
    for(PFUser * subUser in doctors){
        NSString * name = [NSString stringWithFormat:@"%@ %@", subUser[PARSE_USER_FIRSTNAME], subUser[PARSE_USER_LASTSTNAME]];
        if([Util stringIsMatched:name searchKey:key])
            return YES;
    }
    NSArray * nurses = patient[PARSE_PATIENTS_NURSE];
    for(PFUser * subUser in nurses){
        NSString * name = [NSString stringWithFormat:@"%@ %@", subUser[PARSE_USER_FIRSTNAME], subUser[PARSE_USER_LASTSTNAME]];
        if([Util stringIsMatched:name searchKey:key])
            return YES;
    }
    return NO;
}
- (void) reloadTableForIndex:(int)index withSearchKey:(NSString*)searchStr
{
    originalArray = [[NSMutableArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    dataDict = [NSMutableDictionary new];
    if(index == 0){//current patients
        for(PFObject * patientObj in allPatients){
            if([self searchPatientWithKey:searchStr atPatient:patientObj]){
                NSMutableArray * doctors = patientObj[PARSE_PATIENTS_DOCTOR];
                if([self userContainsInUserArray:doctors forUser:me]){
                    [dataArray addObject:patientObj];
                }
            }
        }
    }else if(index == 1){// all patient
        for(PFObject * patientObj in allPatients){
            if([self searchPatientWithKey:searchStr atPatient:patientObj]){
                PFUser * currentDoctor = patientObj[PARSE_PATIENTS_CURRENTDOCTOR];
                if(currentDoctor){
                    NSString * dotorName = [NSString stringWithFormat:@"%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]];
                    NSMutableArray * patientArray = [dataDict objectForKey:dotorName];
                    if(!patientArray){
                        patientArray = [NSMutableArray new];
                        [dataArray addObject:dotorName];
                    }
                    [patientArray addObject:patientObj];
                    [dataDict setObject:patientArray forKey:dotorName];
                }
            }
        }
        dataArray = [[NSMutableArray alloc] initWithArray:[dataArray sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
            return [[obj1 lowercaseString] compare:[obj2 lowercaseString]];
        }]];
    }else if(index == 2){// unseen
        for(PFObject * patientObj in allPatients){
            if([self searchPatientWithKey:searchStr atPatient:patientObj]){
                NSMutableArray * billingArray = patientObj[PARSE_PATIENTS_BILLING];
                if(!billingArray || billingArray.count == 0){
                    [dataArray addObject:patientObj];
                }
            }
        }
    }else if(index == 3){// seen
        for(PFObject * patientObj in allPatients){
            if([self searchPatientWithKey:searchStr atPatient:patientObj]){
                NSMutableArray * billingArray = patientObj[PARSE_PATIENTS_BILLING];
                if(billingArray && billingArray.count > 0){
                    [dataArray addObject:patientObj];
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_date.delegate = self;
        self.tbl_date.dataSource  = self;
        [self.tbl_date reloadData];
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
- (IBAction)onHome:(id)sender {
    DoctorMainMenuViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorMainMenuViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onAdd:(id)sender {
    AddNewPatientViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddNewPatientViewController"];
    controller.runType = APP_RUN_MODE_ADD;
    [self.navigationController pushViewController:controller animated:YES];
}

-(NSLayoutConstraint * )updateMultiplier:(CGFloat)multiplier At:(NSLayoutConstraint*)constraint {
    if(!constraint)
        return nil;
    [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObjects:constraint, nil]];
    
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:multiplier constant:constraint.constant];
    [newConstraint setPriority:constraint.priority];
    newConstraint.shouldBeArchived = constraint.shouldBeArchived;
    newConstraint.identifier = constraint.identifier;
    newConstraint.active = true;
    
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:newConstraint, nil]];
    //NSLayoutConstraint.activateConstraints([newConstraint])
    return newConstraint;
}

- (IBAction)onCurrentPatient:(id)sender {
    self.constant_macro_width = [self updateMultiplier:1/4.f At:self.constant_macro_width];
    self.constant_billing_width = [self updateMultiplier:1/4.f At:self.constant_billing_width];
    self.constant_message_width = [self updateMultiplier:1/4.f At:self.constant_message_width];
    self.constant_note_width = [self updateMultiplier:1/4.f At:self.constant_note_width];
    [self.view setNeedsDisplay];
    
    self.btn_currentPatient.selected = YES;
    self.btn_allpatients.selected = NO;
    self.btn_unseenPatients.selected = NO;
    self.btn_seenPatients.selected = NO;
    runType = 0;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onAllPatient:(id)sender {
    self.constant_macro_width = [self updateMultiplier:0.001/4.f At:self.constant_macro_width];
    self.constant_billing_width = [self updateMultiplier:1/3.f At:self.constant_billing_width];
    self.constant_message_width = [self updateMultiplier:1/3.f At:self.constant_message_width];
    self.constant_note_width = [self updateMultiplier:1/3.f At:self.constant_note_width];
    [self.view setNeedsDisplay];
    
    self.btn_currentPatient.selected = NO;
    self.btn_allpatients.selected = YES;
    self.btn_unseenPatients.selected = NO;
    self.btn_seenPatients.selected = NO;
    runType = 1;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onUnseenPatient:(id)sender {
    self.constant_macro_width = [self updateMultiplier:0.001/4.f At:self.constant_macro_width];
    self.constant_billing_width = [self updateMultiplier:1/3.f At:self.constant_billing_width];
    self.constant_message_width = [self updateMultiplier:1/3.f At:self.constant_message_width];
    self.constant_note_width = [self updateMultiplier:1/3.f At:self.constant_note_width];
    [self.view setNeedsDisplay];
    self.btn_currentPatient.selected = NO;
    self.btn_allpatients.selected = NO;
    self.btn_unseenPatients.selected = YES;
    self.btn_seenPatients.selected = NO;
    runType = 2;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onSeenPatient:(id)sender {
    self.constant_macro_width = [self updateMultiplier:0.001/4.f At:self.constant_macro_width];
    self.constant_billing_width = [self updateMultiplier:1/3.f At:self.constant_billing_width];
    self.constant_message_width = [self updateMultiplier:1/3.f At:self.constant_message_width];
    self.constant_note_width = [self updateMultiplier:1/3.f At:self.constant_note_width];
    [self.view setNeedsDisplay];
    self.btn_currentPatient.selected = NO;
    self.btn_allpatients.selected = NO;
    self.btn_unseenPatients.selected = NO;
    self.btn_seenPatients.selected = YES;
    runType = 3;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onMacroTransfer:(id)sender {
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = doctorArray;
    controller.delegate = self;
    controller.ctrlIndex = 0;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (BOOL) userContainsInUserArray:(NSMutableArray*)array forUser:(PFUser*)user
{
    for(PFUser * subUser in array){
        if([subUser.objectId isEqualToString:user.objectId])
            return YES;
    }
    return NO;
}
- (void) doctorSelected:(PFUser*)user withTag:(int)index
{
    if(index == 0){/// macro transeform
        if(runType == 0){/// all patient
            [self showLoadingBar];
            for(PFObject * patientObj in dataArray){
                int userType = [user[PARSE_USER_TYPE] intValue];
                if(userType == 200){///docto
                    NSMutableArray * doctors = patientObj[PARSE_PATIENTS_DOCTOR];
                    if(!doctors) doctors = [NSMutableArray new];
                    if(![self userContainsInUserArray:doctors forUser:user]){
                        [doctors addObject:user];
                    }
                    patientObj[PARSE_PATIENTS_DOCTOR] = doctors;
                    patientObj[PARSE_PATIENTS_CURRENTDOCTOR] = user;
                }else if(userType == 100){// nurse
                    NSMutableArray * nurse = patientObj[PARSE_PATIENTS_NURSE];
                    if(!nurse) nurse = [NSMutableArray new];
                    if(![self userContainsInUserArray:nurse forUser:user]){
                        [nurse addObject:user];
                    }
                    patientObj[PARSE_PATIENTS_NURSE] = nurse;
                    patientObj[PARSE_PATIENTS_CURRENTNURSE] = user;
                }
                [patientObj saveInBackground];
            }
            allPatients = [NSMutableArray new];
            [self fetchPatient:^(NSMutableArray *array) {
                for (int i=0;i<array.count;i++){
                    PFObject  *owner = [array objectAtIndex:i];
                    [allPatients addObject:owner];
                }
                [self hideLoadingBar];
                [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
            }];
        }
    }else if(index == 1){/// item trans
        [self showLoadingBar];
        int userType = [user[PARSE_USER_TYPE] intValue];
        if(userType == 200){///docto
            NSMutableArray * doctors = selectedPatient[PARSE_PATIENTS_DOCTOR];
            if(!doctors) doctors = [NSMutableArray new];
            if(![self userContainsInUserArray:doctors forUser:user]){
                [doctors addObject:user];
            }
            selectedPatient[PARSE_PATIENTS_DOCTOR] = doctors;
            selectedPatient[PARSE_PATIENTS_CURRENTDOCTOR] = user;
        }else if(userType == 100){// nurse
            NSMutableArray * nurse = selectedPatient[PARSE_PATIENTS_NURSE];
            if(!nurse) nurse = [NSMutableArray new];
            if(![self userContainsInUserArray:nurse forUser:user]){
                [nurse addObject:user];
            }
            selectedPatient[PARSE_PATIENTS_NURSE] = nurse;
            selectedPatient[PARSE_PATIENTS_CURRENTNURSE] = user;
        }
        [selectedPatient saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error){
                [self hideLoadingBar];
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            } else {
                [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                    allPatients = [NSMutableArray new];
                    [self fetchPatient:^(NSMutableArray *array) {
                        for (int i=0;i<array.count;i++){
                            PFObject  *owner = [array objectAtIndex:i];
                            [allPatients addObject:owner];
                        }
                        [self hideLoadingBar];
                        [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
                    }];
                }];
            }
        }];
    }
}


- (IBAction)onBilling:(id)sender {
    DoctorBillingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorBillingViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onNote:(id)sender {
    DoctorNoteListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorNoteListViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onMessage:(id)sender {
    MessageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(runType == 1 && tableView.tag < 1000){
        return [dataArray count];
    }
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(runType == 1  && tableView.tag < 1000){/// all patient
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        return [NSString stringWithFormat:@"%@ (%d)", title, (int)patientArray.count];
    }
    return @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tbl_date){
        if(runType == 1){/// all patient
            NSString * title = [dataArray objectAtIndex:section];
            NSMutableArray * patientArray = [dataDict objectForKey:title];
            return patientArray.count;
        }
        return dataArray.count;
    }
    int index = (int)tableView.tag % 1000;
    PFObject * currentPatient = nil;
    if(runType == 1){/// all patient
        int section = (int)tableView.tag / 1000 - 1;
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        currentPatient = [patientArray objectAtIndex:index];
    }else{
        currentPatient = [dataArray objectAtIndex:index];
    }
    NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
    NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
    return doctors.count + nurses.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tbl_date){
        if(runType == 1){/// all patient
            if(selectedRowIndex == indexPath.row && selectedSectionIndex == indexPath.section){
                NSString * title = [dataArray objectAtIndex:indexPath.section];
                NSMutableArray * patientArray = [dataDict objectForKey:title];
                PFObject * currentPatient = [patientArray objectAtIndex:indexPath.row];
                NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
                NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
                int estimateHeight = ((int)doctors.count + (int)nurses.count + 1) * 34 + 48;
                return estimateHeight;
            }else{
                return 48;
            }
        }else if(selectedRowIndex == indexPath.row){
            PFObject * currentPatient = [dataArray objectAtIndex:indexPath.row];
            NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
            NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
            int estimateHeight = ((int)doctors.count + (int)nurses.count + 1) * 34 + 48;
            return estimateHeight;
        }else{
            return 48;
        }
    }
    return 34;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tv == self.tbl_date){
        static NSString *cellIdentifier = @"DoctorHomeHeaderCell";
        DoctorHomeHeaderCell *cell = (DoctorHomeHeaderCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.mainContainer.layer.cornerRadius = 5.f;
            cell.view_color_container.layer.cornerRadius = 5.f;
            [cell.view_color_container setBackgroundColor:[UIColor clearColor]];
            cell.img_arrow_right.hidden = NO;
            cell.img_arrow_bottom.hidden = YES;
            cell.btn_doctor.hidden = NO;
            if(runType == 1){/// all patient
                if(indexPath.row == selectedRowIndex && indexPath.section == selectedSectionIndex){
                    [cell.view_color_container setBackgroundColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]];
                    cell.img_arrow_right.hidden = YES;
                    cell.img_arrow_bottom.hidden = NO;
                    cell.btn_doctor.hidden = YES;
                }
            }else {
                if(indexPath.row == selectedRowIndex){
                    [cell.view_color_container setBackgroundColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]];
                    cell.img_arrow_right.hidden = YES;
                    cell.img_arrow_bottom.hidden = NO;
                    cell.btn_doctor.hidden = YES;
                }
            }
            PFObject * currentPatient = nil;
            if(runType == 1){/// all patient
                NSString * title = [dataArray objectAtIndex:indexPath.section];
                NSMutableArray * patientArray = [dataDict objectForKey:title];
                currentPatient = [patientArray objectAtIndex:indexPath.row];
            }else{
                currentPatient = [dataArray objectAtIndex:indexPath.row];
            }
            cell.lbl_number.text = currentPatient[PARSE_PATIENTS_RECORDNUMBER];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", currentPatient[PARSE_PATIENTS_FIRSTNAME], currentPatient[PARSE_PATIENTS_LASTNAME]];
            PFUser * currentDoctor = currentPatient[PARSE_PATIENTS_CURRENTDOCTOR];
            cell.btn_doctor.layer.cornerRadius = 5.f;
            cell.btn_doctor.tag = indexPath.row + 1000*indexPath.section;
            [cell.btn_doctor setTitle:@"Transfer" forState:UIControlStateNormal];

            [cell.btn_doctor addTarget:self action:@selector(onClickDoctorButton:) forControlEvents:UIControlEventTouchUpInside];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.tbl_data.tag = indexPath.row + 1000*(indexPath.section + 1);
                cell.tbl_data.delegate = self;
                cell.tbl_data.dataSource = self;
                [cell.tbl_data reloadData];
            });
            cell.btn_collapse.tag = indexPath.row + 1000*indexPath.section;
            [cell.btn_collapse addTarget:self action:@selector(onCollape:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell resizeNumberLabel];
        return cell;
    }else{
        int index = (int)tv.tag % 1000;
        int section = (int)tv.tag / 1000 - 1;
        PFObject * currentPatient = nil;
        if(runType == 1){/// all patient
            NSString * title = [dataArray objectAtIndex:section];
            NSMutableArray * patientArray = [dataDict objectForKey:title];
            currentPatient = [patientArray objectAtIndex:index];
        }else{
            currentPatient = [dataArray objectAtIndex:index];
        }
        PFUser * currentDoctor = currentPatient[PARSE_PATIENTS_CURRENTDOCTOR];
        NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
        NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
        if(indexPath.row < doctors.count + nurses.count){
            static NSString *cellIdentifier = @"DoctorHomeDoctorCell";
            DoctorHomeDoctorCell *cell = (DoctorHomeDoctorCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell){
                PFUser * currentUser = nil;
                NSString * userName = @"";
                if(indexPath.row < doctors.count){
                    currentUser = doctors[indexPath.row];
                    userName = [NSString stringWithFormat:@"Dr. %@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
                }else{
                    currentUser = nurses[indexPath.row - doctors.count];
                    userName = [NSString stringWithFormat:@"%@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
                }
                cell.btn_message.hidden = YES;
                if([currentUser.objectId isEqualToString:me.objectId]){
                    cell.btn_message.hidden = YES;
                }else{
                    cell.btn_message.hidden = NO;
                }
                cell.lbl_title.text = userName;
                cell.btn_message.tag = indexPath.row + index * 1000 + section * 10000;
                [cell.btn_message addTarget:self action:@selector(onSendMessage:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }else{
            static NSString *cellIdentifier = @"DoctorHomeActionCell";
            DoctorHomeActionCell *cell = (DoctorHomeActionCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell){
                cell.btn_note.layer.cornerRadius = 5.f;
                cell.btn_doctor.layer.cornerRadius = 5.f;
                cell.btn_note.tag = index+ 1000*section;
                cell.btn_doctor.tag = index+ 1000*section;
                if([currentDoctor.objectId isEqualToString:me.objectId]){
                    [cell.btn_doctor setTitle:[NSString stringWithFormat:@"%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]] forState:UIControlStateNormal];
                }else{
                    [cell.btn_doctor setTitle:@"Transfer" forState:UIControlStateNormal];
                }
                [cell.btn_note addTarget:self action:@selector(onSelectNote:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_doctor addTarget:self action:@selector(onSelectTransfer:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView == self.tbl_date){
        PFObject * currentPatient = nil;
        if(runType == 1){/// all patient
            NSString * title = [dataArray objectAtIndex:indexPath.section];
            NSMutableArray * patientArray = [dataDict objectForKey:title];
            currentPatient = [patientArray objectAtIndex:indexPath.row];
        }else{
            currentPatient = [dataArray objectAtIndex:indexPath.row];
        }
        AddNewPatientViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddNewPatientViewController"];
        controller.runType = APP_RUN_MODE_EDIT;
        controller.currentPatient = currentPatient;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (void) onCollape:(UIButton*) button
{
    int index = (int)button.tag % 1000;
    int section = (int)button.tag / 1000;
    
    if(runType == 1){/// all patient
        if(selectedSectionIndex == section && selectedRowIndex == index){
            selectedRowIndex = -1;
            selectedSectionIndex = -1;
        }else{
            selectedRowIndex = index;
            selectedSectionIndex = section;
        }
    }else{
        if(selectedRowIndex == index){
            selectedRowIndex = -1;
        }else{
            selectedRowIndex = index;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_date.delegate = self;
        self.tbl_date.dataSource  = self;
        [self.tbl_date reloadData];
    });
}

- (void) onClickDoctorButton:(UIButton *) button
{
    int index = (int)button.tag % 1000;
    int section = (int)button.tag / 1000;
    PFObject * currentPatient = nil;
    if(runType == 1){/// all patient
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        currentPatient = [patientArray objectAtIndex:index];
    }else{
        currentPatient = [dataArray objectAtIndex:index];
    }
    selectedPatient = currentPatient;
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = doctorArray;
    controller.delegate = self;
    controller.ctrlIndex = 1;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void) onSelectNote:(UIButton *) button
{
    int index = (int)button.tag % 1000;
    int section = (int)button.tag / 1000;
    PFObject * currentPatient = nil;
    if(runType == 1){/// all patient
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        currentPatient = [patientArray objectAtIndex:index];
    }else{
        currentPatient = [dataArray objectAtIndex:index];
    }
    DoctorNoteListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorNoteListViewController"];
    controller.selectedPatientObj = currentPatient;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void) onSelectTransfer:(UIButton *) button
{
    int index = (int)button.tag % 1000;
    int section = (int)button.tag / 1000;
    PFObject * currentPatient = nil;
    if(runType == 1){/// all patient
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        currentPatient = [patientArray objectAtIndex:index];
    }else{
        currentPatient = [dataArray objectAtIndex:index];
    }
    selectedPatient = currentPatient;
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = doctorArray;
    controller.delegate = self;
    controller.ctrlIndex = 1;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
    
}
- (void) onSendMessage:(UIButton * ) button
{
    int tvIndex = (int)button.tag / 10000;
    int section = ((int)button.tag - tvIndex*10000) / 1000;
    int index = section;
    int rowIndex = ((int)button.tag - tvIndex*10000) % 1000;
    PFObject * currentPatient = nil;
    if(runType == 1){/// all patient
        NSString * title = [dataArray objectAtIndex:section];
        NSMutableArray * patientArray = [dataDict objectForKey:title];
        currentPatient = [patientArray objectAtIndex:index];
    }else{
        currentPatient = [dataArray objectAtIndex:index];
    }
    NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
    NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
    PFUser * currentUser = nil;
    if(rowIndex < doctors.count){
        currentUser = doctors[rowIndex];
    }else{
        currentUser = nurses[rowIndex - doctors.count];
    }
    [super onSendMessageTo:currentUser inPatient:currentPatient];
}
@end
