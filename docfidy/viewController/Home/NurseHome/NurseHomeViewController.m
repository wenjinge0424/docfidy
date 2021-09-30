//
//  NurseHomeViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/31/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "NurseHomeViewController.h"
#import "SelectDoctorViewController.h"
#import "DoctorHomeTableViewCell.h"
#import "NurseMainMenuViewController.h"
#import "MessageViewController.h"
static NurseHomeViewController * _clentHome;
@interface NurseHomeViewController ()<UITableViewDelegate, UITableViewDataSource, SelectDoctorViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray * doctorArray;
    NSMutableArray * allPatients;
    int runType;
    NSMutableArray * dataArray;
    NSMutableDictionary * dataDict;
    PFUser * me;
    
    int selectedRowIndex;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_currentPatient;
@property (weak, nonatomic) IBOutlet UIButton *btn_unseenPatients;
@property (weak, nonatomic) IBOutlet UIButton *btn_seenPatients;

@property (weak, nonatomic) IBOutlet UITextField *edt_search;
@property (weak, nonatomic) IBOutlet UITableView *tbl_date;

@property (weak, nonatomic) IBOutlet UIView *view_badgeContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_bageNumber;
@end

@implementation NurseHomeViewController
+ (NurseHomeViewController*) createInstance
{
    return _clentHome;
}

- (void) setBageCount
{
    me = [PFUser currentUser];
    NSString * keyStr = me.objectId;
    NSUserDefaults * userDefault =  [NSUserDefaults standardUserDefaults];
    int unreadCount = [[userDefault objectForKey:keyStr] intValue];
    if(unreadCount == 0){
        [self.view_badgeContainer setHidden:YES];
    }else{
        [self.view_badgeContainer setHidden:NO];
        [self.lbl_bageNumber setText:[NSString stringWithFormat:@"%d", unreadCount]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view_badgeContainer.layer.cornerRadius = self.view_badgeContainer.frame.size.width / 2.f;
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    me = [PFUser currentUser];
    runType = 0;
    selectedRowIndex = -1;
    self.edt_search.delegate = self;
    [self fetchData];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _clentHome = self;
    [self setBageCount];
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _clentHome = nil;
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    doctorArray = [[NSMutableArray alloc] init];
    allPatients = [NSMutableArray new];
    [self showLoadingBar];
    PFQuery * doctorquery = [PFUser query];
    [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    PFQuery * nursequery = [PFUser query];
    [nursequery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
    
    PFQuery * userQuery = [PFQuery orQueryWithSubqueries:@[doctorquery, nursequery]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
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
            [query whereKey:PARSE_PATIENTS_NURSE containedIn:@[me]];
            [query orderByDescending:PARSE_FIELD_UPDATED_AT];
            [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [self hideLoadingBar];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFObject  *owner = [array objectAtIndex:i];
                        [allPatients addObject:owner];
                    }
                }
                [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
            }];
        }
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

- (void) reloadTableForIndex:(int)index withSearchKey:searchStr
{
    dataArray = [[NSMutableArray alloc] init];
    dataDict = [NSMutableDictionary new];
    if(index == 0){//current patients
        for(PFObject * patientObj in allPatients){
            if([self searchPatientWithKey:searchStr atPatient:patientObj]){
                [dataArray addObject:patientObj];
            }
        }
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
    NurseMainMenuViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NurseMainMenuViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onCurrentPatient:(id)sender {
    self.btn_currentPatient.selected = YES;
    self.btn_unseenPatients.selected = NO;
    self.btn_seenPatients.selected = NO;
    runType = 0;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onMessage:(id)sender {
    me = [PFUser currentUser];
    NSString * keyStr = me.objectId;
    NSUserDefaults * userDefault =  [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInt:0] forKey:keyStr];
    
    MessageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onUnseenPatient:(id)sender {
    self.btn_currentPatient.selected = NO;
    self.btn_unseenPatients.selected = YES;
    self.btn_seenPatients.selected = NO;
    runType = 2;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}
- (IBAction)onSeenPatient:(id)sender {
    self.btn_currentPatient.selected = NO;
    self.btn_unseenPatients.selected = NO;
    self.btn_seenPatients.selected = YES;
    runType = 3;
    [self reloadTableForIndex:runType withSearchKey:self.edt_search.text];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tbl_date){
        return dataArray.count;
    }
    int index = (int)tableView.tag - 1000;
    PFObject * currentPatient = [dataArray objectAtIndex:index];
    NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
    NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
    return doctors.count + nurses.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tbl_date){
        if(selectedRowIndex == indexPath.row){
            PFObject * currentPatient = [dataArray objectAtIndex:indexPath.row];
            NSArray * doctors = currentPatient[PARSE_PATIENTS_DOCTOR];
            NSArray * nurses = currentPatient[PARSE_PATIENTS_NURSE];
            int estimateHeight = ((int)doctors.count + (int)nurses.count) * 34 + 48;
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
            if(indexPath.row == selectedRowIndex){
                [cell.view_color_container setBackgroundColor:[UIColor colorWithRed:0 green:122/255.f blue:1 alpha:1]];
                cell.img_arrow_right.hidden = YES;
                cell.img_arrow_bottom.hidden = NO;
                cell.btn_doctor.hidden = YES;
            }else{
                [cell.view_color_container setBackgroundColor:[UIColor clearColor]];
                cell.img_arrow_right.hidden = NO;
                cell.img_arrow_bottom.hidden = YES;
                cell.btn_doctor.hidden = NO;
            }
            
            PFObject * currentPatient = [dataArray objectAtIndex:indexPath.row];
            cell.lbl_number.text = currentPatient[PARSE_PATIENTS_RECORDNUMBER];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", currentPatient[PARSE_PATIENTS_FIRSTNAME], currentPatient[PARSE_PATIENTS_LASTNAME]];
            PFUser * currentDoctor = currentPatient[PARSE_PATIENTS_CURRENTDOCTOR];
            cell.btn_doctor.layer.cornerRadius = 5.f;
            cell.btn_doctor.tag = indexPath.row;
            [cell.btn_doctor setHidden:YES];
            if([currentDoctor.objectId isEqualToString:me.objectId]){
                [cell.btn_doctor setTitle:[NSString stringWithFormat:@"%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]] forState:UIControlStateNormal];
            }else{
                [cell.btn_doctor setTitle:@"Transfer" forState:UIControlStateNormal];
            }
            [cell.btn_doctor addTarget:self action:@selector(onClickDoctorButton:) forControlEvents:UIControlEventTouchUpInside];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.tbl_data.tag = indexPath.row + 1000;
                cell.tbl_data.delegate = self;
                cell.tbl_data.dataSource = self;
                [cell.tbl_data reloadData];
            });
            cell.btn_collapse.tag = indexPath.row;
            [cell.btn_collapse addTarget:self action:@selector(onCollape:) forControlEvents:UIControlEventTouchUpInside];
            [cell resizeNumberLabel];
        }
        return cell;
    }else{
        int index = (int)tv.tag - 1000;
        PFObject * currentPatient = [dataArray objectAtIndex:index];
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
                cell.btn_message.tag = indexPath.row + index * 1000;
                [cell.btn_message addTarget:self action:@selector(onSendMessage:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }else{
            static NSString *cellIdentifier = @"DoctorHomeActionCell";
            DoctorHomeActionCell *cell = (DoctorHomeActionCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
            if(cell){
                cell.btn_note.layer.cornerRadius = 5.f;
                cell.btn_doctor.layer.cornerRadius = 5.f;
                cell.btn_note.tag = index;
                cell.btn_doctor.tag = index;
                if([currentDoctor.objectId isEqualToString:me.objectId]){
                    [cell.btn_doctor setTitle:[NSString stringWithFormat:@"%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]] forState:UIControlStateNormal];
                }else{
                    [cell.btn_doctor setTitle:@"Transfer" forState:UIControlStateNormal];
                }
                [cell.btn_note addTarget:self action:@selector(onSelectNote:) forControlEvents:UIControlEventTouchUpInside];
                [cell.btn_note addTarget:self action:@selector(onSelectTransfer:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
        self.tbl_date.delegate = self;
        self.tbl_date.dataSource  = self;
        [self.tbl_date reloadData];
    });
}

- (void) onClickDoctorButton:(UIButton *) button
{
}
- (void) onSelectNote:(UIButton *) button
{
}
- (void) onSelectTransfer:(UIButton *) button
{
}
- (void) onSendMessage:(UIButton * ) button
{
    int index = (int)button.tag / 1000;
    int rowIndex = button.tag % 1000;
    PFObject * currentPatient = [dataArray objectAtIndex:index];
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
