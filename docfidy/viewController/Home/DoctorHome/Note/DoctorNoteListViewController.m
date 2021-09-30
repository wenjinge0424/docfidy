//
//  DoctorNoteListViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorNoteListViewController.h"
#import "DoctorNoteTableViewCell.h"
#import "EditNoteViewController.h"

@interface DoctorNoteListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * dataArray;
    NSMutableArray * doctorArray;
    PFUser * me;
    NSMutableArray * relationNotes;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_patientTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_recordNum;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_patientTitle_height;
@property (weak, nonatomic) IBOutlet UIView *view_noteContainer;
@end

@implementation DoctorNoteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [self.view_noteContainer setHidden:YES];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.selectedPatientObj){
        [self.view_noteContainer setHidden:NO];
        self.lbl_patientTitle.text = [NSString stringWithFormat:@"%@ %@", self.selectedPatientObj[PARSE_PATIENTS_FIRSTNAME], self.selectedPatientObj[PARSE_PATIENTS_LASTNAME]];
        self.lbl_recordNum.text = self.selectedPatientObj[PARSE_PATIENTS_RECORDNUMBER];
        self.constant_patientTitle_height.constant = 60;
        [self.view setNeedsLayout];
    }else{
        [self.view_noteContainer setHidden:YES];
        self.constant_patientTitle_height.constant = 0;
        [self.view setNeedsLayout];
    }
    [self fetchData];
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    doctorArray = [NSMutableArray new];
    relationNotes = [NSMutableArray new];
    [self showLoadingBar];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_NOTE];
    [query whereKey:PARSE_NOTE_OWNER equalTo:me];
    if(self.selectedPatientObj){
        [query whereKey:PARSE_NOTE_PATIENT equalTo:self.selectedPatientObj];
    }
    [query includeKey:PARSE_NOTE_OWNER];
    [query includeKey:PARSE_NOTE_PATIENT];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            dataArray = (NSMutableArray*)array;
            
            PFQuery * doctorquery = [PFUser query];
            [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
            [doctorquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                if (error){
                    [self hideLoadingBar];
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFUser *owner = [array objectAtIndex:i];
                        [doctorArray addObject:owner];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideLoadingBar];
                        self.tbl_data.delegate = self;
                        self.tbl_data.dataSource  = self;
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
- (IBAction)onAdd:(id)sender {
    EditNoteViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditNoteViewController"];
    controller.runTypeMode = APP_RUN_MODE_ADD;
    if(self.selectedPatientObj){
        controller.relationPatient = self.selectedPatientObj;
    }
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DoctorNoteTableViewCell";
    DoctorNoteTableViewCell *cell = (DoctorNoteTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFObject * noteDict = [dataArray objectAtIndex:indexPath.row];
        NSDictionary * patient = noteDict[PARSE_NOTE_PATIENT];
        PFUser * currentDoctor = patient[PARSE_PATIENTS_CURRENTDOCTOR];
        currentDoctor = [super getUserFromId:currentDoctor.objectId inArray:doctorArray];
        cell.lbl_patient.text = [NSString stringWithFormat:@"%@ %@", patient[PARSE_PATIENTS_FIRSTNAME], patient[PARSE_PATIENTS_LASTNAME]];
        if(currentDoctor){
            cell.lbl_name.text = [NSString stringWithFormat:@"Dr.%@ %@", currentDoctor[PARSE_USER_FIRSTNAME], currentDoctor[PARSE_USER_LASTSTNAME]];
        }
        cell.lbl_detail.text = noteDict[PARSE_NOTE_DESCRIPTION];
        cell.lbl_time.text = [Util convertDateToString:noteDict.updatedAt];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject * noteDict = [dataArray objectAtIndex:indexPath.row];
    EditNoteViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditNoteViewController"];
    controller.runTypeMode = APP_RUN_MODE_EDIT;
    controller.noteObject = noteDict;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
