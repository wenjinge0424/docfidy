//
//  PatientDetailViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "PatientDetailViewController.h"
#import "PatientTableViewCell.h"
#import "TitleTableViewCell.h"
#import "CommentsViewController.h"
#import "SelectDoctorViewController.h"
#import "MessageViewController.h"

@interface PatientDetailViewController ()<UITableViewDelegate, UITableViewDataSource, SelectDoctorViewControllerDelegate>
{
    NSMutableArray * allUsers;
    NSMutableArray * doctors;
    NSMutableArray * nurses;
    NSMutableArray * diagnosis;
    NSMutableArray * visites;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;

@end

@implementation PatientDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (PFUser*) getUserInfo:(NSString*)objectId
{
    for(PFUser * user in allUsers){
        if([user.objectId isEqualToString:objectId])
            return user;
    }
    return nil;
}
- (NSMutableArray *) getUserFromIds:(NSMutableArray*)userIds
{
    NSMutableArray * users = [NSMutableArray new];
    for(PFUser * user in userIds){
        NSString * objectId = user.objectId;
        [users addObject:[self getUserInfo:objectId]];
    }
    return users;
}
- (void) fetchData
{
    allUsers = [NSMutableArray new];
    doctors = [NSMutableArray new];
    nurses = [NSMutableArray new];
    visites = [NSMutableArray new];
    diagnosis = self.patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
    
    [self showLoadingBar];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [allUsers addObject:owner];
            }
            
            doctors = [self getUserFromIds:self.patientObj[PARSE_PATIENTS_DOCTOR]];
            nurses = [self getUserFromIds:self.patientObj[PARSE_PATIENTS_NURSE]];
            
            PFQuery * note_query = [PFQuery queryWithClassName:PARSE_TABLE_NOTE];
            [note_query whereKey:PARSE_NOTE_PATIENT equalTo:self.patientObj];
            [note_query includeKey:PARSE_NOTE_OWNER];
            [note_query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [self hideLoadingBar];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFUser *owner = [array objectAtIndex:i];
                        [visites addObject:owner];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.tbl_data.delegate = self;
                        self.tbl_data.dataSource = self;
                        [self.tbl_data reloadData];
                    });
                }
            }];
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
- (IBAction)onMessage:(id)sender {
    MessageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onNote:(id)sender {
    CommentsViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    controller.patientObj = self.patientObj;
    controller.noteArray = visites;
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1+1+doctors.count+1+nurses.count+1+diagnosis.count+1+visites.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 170;
    if(indexPath.row == 1) return 40;
    if(indexPath.row > 1 && indexPath.row < 1+1+doctors.count) return 30;
    if(indexPath.row == 1+1+doctors.count) return 40;
    if(indexPath.row > 1+1+doctors.count && indexPath.row < 1+1+doctors.count+1+nurses.count) return 30;
    if(indexPath.row == 1+1+doctors.count+1+nurses.count) return 40;
    if(indexPath.row > 1+1+doctors.count+1+nurses.count && indexPath.row < 1+1+doctors.count+1+nurses.count+1+diagnosis.count) return 30;
    if(indexPath.row == 1+1+doctors.count+1+nurses.count+1+diagnosis.count) return 40;
    if(indexPath.row > 1+1+doctors.count+1+nurses.count+1+diagnosis.count) return 60;
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        static NSString *cellIdentifier = @"Title_PatientTableViewCell";
        Title_PatientTableViewCell *cell = (Title_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_patientName.text = [NSString stringWithFormat:@"%@ %@", self.patientObj[PARSE_PATIENTS_FIRSTNAME], self.patientObj[PARSE_PATIENTS_LASTNAME]];
            cell.lbl_recordNum.text = self.patientObj[PARSE_PATIENTS_RECORDNUMBER];
            cell.lbl_birthday.text = [Util convertDateToString:self.patientObj[PARSE_PATIENTS_BIRTH]];
            cell.btnDischarge.hidden = YES;
            if(self.runType == 2){//current
                int state = [self.patientObj[PARSE_PATIENTS_STATE] intValue];
                if(state != 2){
                    cell.btnDischarge.hidden = NO;
                    [cell.btnDischarge addTarget:self action:@selector(onDischargePatient:) forControlEvents:UIControlEventTouchUpInside];
                }
            }else{
                cell.btnDischarge.hidden = YES;
            }
        }
        return cell;
    }
    if(indexPath.row == 1){
        static NSString *cellIdentifier = @"Action_PatientTableViewCell";
        Action_PatientTableViewCell *cell = (Action_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_title.text = @"Doctor(s)";
            cell.btn_transfer.hidden = NO;
            [cell.btn_transfer addTarget:self action:@selector(onSelectDoctor:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    if(indexPath.row > 1 && indexPath.row < 1+1+doctors.count) {
        static NSString *cellIdentifier = @"List_PatientTableViewCell";
        List_PatientTableViewCell *cell = (List_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            int index = (int)indexPath.row - 1-1;
            PFUser * doctor = [doctors objectAtIndex:index];
            cell.lbl_title.text = [NSString stringWithFormat:@"Dr. %@ %@", doctor[PARSE_USER_FIRSTNAME], doctor[PARSE_USER_LASTSTNAME]];
            cell.btn_message.tag = indexPath.row;
            [cell.btn_message addTarget:self action:@selector(onSendMessageAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_delete.tag = indexPath.row;
            [cell.btn_delete addTarget:self action:@selector(onDeleteUser:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    if(indexPath.row == 1+1+doctors.count) {
        static NSString *cellIdentifier = @"Action_PatientTableViewCell";
        Action_PatientTableViewCell *cell = (Action_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_title.text = @"Nurse(s)";
            cell.btn_transfer.hidden = NO;
            [cell.btn_transfer addTarget:self action:@selector(onSelectNurse:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    if(indexPath.row > 1+1+doctors.count && indexPath.row < 1+1+doctors.count+1+nurses.count){
        static NSString *cellIdentifier = @"List_PatientTableViewCell";
        List_PatientTableViewCell *cell = (List_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            int index = (int)indexPath.row - 1-1-(int)doctors.count-1;
            PFUser * nurse = [nurses objectAtIndex:index];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", nurse[PARSE_USER_FIRSTNAME], nurse[PARSE_USER_LASTSTNAME]];
            cell.btn_message.tag = indexPath.row;
            [cell.btn_message addTarget:self action:@selector(onSendMessageAtIndex:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_delete.tag = indexPath.row;
            [cell.btn_delete addTarget:self action:@selector(onDeleteUser:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    if(indexPath.row == 1+1+doctors.count+1+nurses.count) {
        static NSString *cellIdentifier = @"Action_PatientTableViewCell";
        Action_PatientTableViewCell *cell = (Action_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_title.text = @"Diagnosis";
            cell.btn_transfer.hidden = YES;
        }
        return cell;
    }
    if(indexPath.row > 1+1+doctors.count+1+nurses.count && indexPath.row < 1+1+doctors.count+1+nurses.count+1+diagnosis.count) {
        static NSString *cellIdentifier = @"TitleTableViewCell";
        TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            int index = (int)indexPath.row - 1-1-(int)doctors.count-1-(int)nurses.count-1;
            NSString * strDiagnosis = [diagnosis objectAtIndex:index];
            cell.lbl_title.text = strDiagnosis;
        }
        return cell;
    }
    if(indexPath.row == 1+1+doctors.count+1+nurses.count+1+diagnosis.count) {
        static NSString *cellIdentifier = @"Action_PatientTableViewCell";
        Action_PatientTableViewCell *cell = (Action_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.lbl_title.text = @"Doctor visits";
            cell.btn_transfer.hidden = YES;
        }
        return cell;
    }
    if(indexPath.row > 1+1+doctors.count+1+nurses.count+1+diagnosis.count) {
        static NSString *cellIdentifier = @"Visit_PatientTableViewCell";
        Visit_PatientTableViewCell *cell = (Visit_PatientTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            int index = (int)indexPath.row - 1-1-(int)doctors.count-1-(int)nurses.count-1-(int)diagnosis.count-1;
            PFObject * noteInfo = [visites objectAtIndex:index];
            PFUser * owner = noteInfo[PARSE_NOTE_OWNER];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", owner[PARSE_USER_FIRSTNAME], owner[PARSE_USER_LASTSTNAME]];
            cell.lbl_detail.text = [Util convertDateTimeToString:noteInfo.updatedAt];
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void) onDischargePatient:(UIButton*)button
{
    [self showLoadingBar];
    self.patientObj[PARSE_PATIENTS_STATE] = [NSNumber numberWithInt:2];
    [self.patientObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self hideLoadingBar];
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
- (void) onSendMessageAtIndex:(UIButton*)button
{
    int index = (int)button.tag;
    if(index > 1 && index < 1+1+doctors.count) {
        int nIndex = (int)index - 1-1;
        PFUser * doctor = [doctors objectAtIndex:nIndex];
        [super onSendMessageTo:doctor inPatient:self.patientObj];
    }else if(index > 1+1+doctors.count && index < 1+1+doctors.count+1+nurses.count){
        int nIndex = (int)index - 1-1-(int)doctors.count-1;
        PFUser * nurse = [nurses objectAtIndex:nIndex];
        [super onSendMessageTo:nurse inPatient:self.patientObj];
    }
}
- (NSMutableArray*) removeUserInUserArray:(NSMutableArray*)array forUser:(PFUser*)user
{
    NSMutableArray * newUserArray = [NSMutableArray new];
    for(PFUser * subUser in array){
        if(![subUser.objectId isEqualToString:user.objectId]){
            [newUserArray addObject:user];
        }
    }
    return newUserArray;
}
- (void) onDeleteUser:(UIButton*)button
{
    int index = (int)button.tag;
    if(index > 1 && index < 1+1+doctors.count) {
        int nIndex = (int)index - 1-1;
        PFUser * doctor = [doctors objectAtIndex:nIndex];
        doctors = [self removeUserInUserArray:doctors forUser:doctor];
    }else if(index > 1+1+doctors.count && index < 1+1+doctors.count+1+nurses.count){
        int nIndex = (int)index - 1-1-(int)doctors.count-1;
        PFUser * nurse = [nurses objectAtIndex:nIndex];
        nurses = [self removeUserInUserArray:nurses forUser:nurse];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingBar];
        self.patientObj[PARSE_PATIENTS_DOCTOR] = doctors;
        self.patientObj[PARSE_PATIENTS_NURSE] = nurses;
        [self.patientObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self hideLoadingBar];
            self.tbl_data.delegate = self;
            self.tbl_data.dataSource = self;
            [self.tbl_data reloadData];
        }];
        
    });
}

- (void) onSelectDoctor:(UIButton*)button
{
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = [AppStateManager sharedInstance].doctorArray;
    controller.ExceptionArray = doctors;
    controller.needAnyDoctor = YES;
    controller.delegate = self;
    controller.ctrlIndex = 0;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void) onSelectNurse:(UIButton*)button
{
    SelectDoctorViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectDoctorViewController"];
    controller.doctorArray = [AppStateManager sharedInstance].doctorArray;
    controller.ExceptionArray = doctors;
    controller.needAnyDoctor = NO;
    controller.needAnyNurse = YES;
    controller.delegate = self;
    controller.ctrlIndex = 1;
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
    if(index == 0){// selected Doctor
        if(!doctors || doctors.count == 0)
            doctors = [NSMutableArray new];
        if(![self userContainsInUserArray:doctors forUser:user])
            [doctors addObject:user];
    }else{// selected Nurse
        if(!nurses || nurses.count == 0)
            nurses = [NSMutableArray new];
        if(![self userContainsInUserArray:nurses forUser:user])
            [nurses addObject:user];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingBar];
        self.patientObj[PARSE_PATIENTS_DOCTOR] = doctors;
        self.patientObj[PARSE_PATIENTS_NURSE] = nurses;
        [self.patientObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self hideLoadingBar];
            self.tbl_data.delegate = self;
            self.tbl_data.dataSource = self;
            [self.tbl_data reloadData];
        }];
        
    });
}
@end
