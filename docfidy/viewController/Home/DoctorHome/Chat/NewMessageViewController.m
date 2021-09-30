//
//  NewMessageViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "NewMessageViewController.h"
#import "TitleTableViewCell.h"
#import "MessageRecipeViewController.h"

@interface NewMessageViewController ()<UITableViewDelegate, UITableViewDataSource, MessageRecipeViewControllerDelegate>
{
    NSMutableArray * allGroups;
    NSMutableArray * allDoctors;
    NSMutableArray * selectedDoctors;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_groupName;
@property (weak, nonatomic) IBOutlet UITableView *tbl_groups;
@property (weak, nonatomic) IBOutlet UITableView *tbl_doctors;

@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_groupName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_groupName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
//    [self reloadTables];
}
- (void) fetchData
{
    allGroups = [NSMutableArray new];
    allDoctors = [NSMutableArray new];
    selectedDoctors = [NSMutableArray new];
    [self showLoadingBar];
    PFUser * me = [PFUser currentUser];
    PFQuery * query = [PFQuery  queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query whereKey:PARSE_ROOM_PARTICIPANTS containedIn:@[me]];
    [query whereKey:PARSE_ROOM_ISGROUP equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<objects.count;i++){
                PFObject  * group = [objects objectAtIndex:i];
                [allGroups addObject:group];
            }
        }
        
        NSMutableArray * registedDoctors = [AppStateManager sharedInstance].doctorArray;
        for(PFUser * subDoctor in registedDoctors){
            if(![subDoctor.objectId isEqualToString:me.objectId]){
                [allDoctors addObject:subDoctor];
            }
        }
        [self reloadTables];
        
    }];
}
- (void) reloadTables
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_groups.delegate = self;
        self.tbl_groups.dataSource = self;
        [self.tbl_groups reloadData];
        self.tbl_doctors.delegate = self;
        self.tbl_doctors.dataSource = self;
        [self.tbl_doctors reloadData];
    });
}
- (BOOL) doctorContainsIn:(NSMutableArray*)doctors forDoctor:(PFUser*)doctor
{
    for(PFUser * subDoctor in doctors){
        if([subDoctor.objectId isEqualToString:doctor.objectId]){
            return YES;
        }
    }
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
- (IBAction)onDone:(id)sender {
    if(selectedDoctors.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select doctors."];
    }else if(self.edt_groupName.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter group name."];
    }else{
        [selectedDoctors addObject:[PFUser currentUser]];
        PFObject * obj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
        obj[PARSE_ROOM_IS_READ] = [NSNumber numberWithBool:NO];
        obj[PARSE_ROOM_PARTICIPANTS] = selectedDoctors;
        obj[PARSE_ROOM_GROUPNAME] = self.edt_groupName.text;
        obj[PARSE_ROOM_ISGROUP] = [NSNumber numberWithBool:YES];
        
        [self showLoadingBar];
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tbl_groups)
        return allGroups.count;
    return allDoctors.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        if(tv == self.tbl_groups){
            PFObject * groupInfo = [allGroups objectAtIndex:indexPath.row];
            cell.lbl_title.text = groupInfo[PARSE_ROOM_GROUPNAME];
        }else{
            PFUser * doctorInfo = [allDoctors objectAtIndex:indexPath.row];
            cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", doctorInfo[PARSE_USER_FIRSTNAME], doctorInfo[PARSE_USER_LASTSTNAME]];
            cell.img_checker.hidden = YES;
            if([self doctorContainsIn:selectedDoctors forDoctor:doctorInfo]){
                cell.img_checker.hidden = NO;
            }
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView == self.tbl_groups){
        PFObject * groupInfo = [allGroups objectAtIndex:indexPath.row];
        MessageRecipeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessageRecipeViewController"];
        controller.delegate = self;
        controller.alreadySelectedDoctors = groupInfo[PARSE_ROOM_PARTICIPANTS];
        controller.messageRoomObj = groupInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        PFUser * doctorInfo = [allDoctors objectAtIndex:indexPath.row];
        NSMutableArray * newSelectedDoctors = [NSMutableArray new];
        if([self doctorContainsIn:selectedDoctors forDoctor:doctorInfo]){
            for(PFUser * user in selectedDoctors){
                if(![user.objectId isEqualToString:doctorInfo.objectId]){
                    [newSelectedDoctors addObject:user];
                }
            }
            selectedDoctors = newSelectedDoctors;
        }else{
            [selectedDoctors addObject:doctorInfo];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - MessageRecipeViewControllerDelegate
- (void) didmissWithArray:(NSMutableArray *)array
{
    for(PFUser * user in array){
        if(![self doctorContainsIn:selectedDoctors forDoctor:user]){
            [selectedDoctors addObject:user];
        }
    }
    [self reloadTables];
}
@end
