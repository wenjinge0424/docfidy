//
//  MessageViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/31/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "MessageViewController.h"
#import "NewMessageViewController.h"
#import "MessageTableViewCell.h"
#import "ChattingViewController.h"
MessageViewController *_sharedViewController;
@interface MessageViewController ()<UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>
{
    NSMutableArray * allDoctors;
    NSMutableArray * allChannels;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_groups;
@property (weak, nonatomic) IBOutlet UIView *view_msgTag;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sharedViewController = self;
    PFUser * me = [PFUser currentUser];
    if([me[PARSE_USER_TYPE] intValue] == 200){
        [self.view_msgTag setHidden:NO];
    }else{
        [self.view_msgTag setHidden:YES];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:kChatReceiveNotificationMessageRooms object:nil];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _sharedViewController = self;
    [self fetchData];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _sharedViewController = nil;
}
+ (MessageViewController *)getInstance{
    return _sharedViewController;
}
- (void) fetchData
{
    PFUser * me = [PFUser currentUser];
    allChannels = [NSMutableArray new];
    allDoctors = [NSMutableArray new];
    [self showLoadingBar];
    PFQuery * query = [PFQuery  queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query whereKey:PARSE_ROOM_PARTICIPANTS containedIn:@[me]];
    [query whereKey:PARSE_ROOM_DELETEUSER notContainedIn:@[me]];
    [query includeKey:PARSE_ROOM_PARTICIPANTS];
    [query includeKey:PARSE_ROOM_PATIENT];
    [query includeKey:PARSE_ROOM_LAST_MESSAGE];
    [query orderByDescending:PARSE_FIELD_UPDATED_AT];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<objects.count;i++){
                PFObject  * group = [objects objectAtIndex:i];
                [allChannels addObject:group];
            }
        }
        
        NSMutableArray * registedDoctors = [AppStateManager sharedInstance].doctorArray;
        for(PFUser * subDoctor in registedDoctors){
            [allDoctors addObject:subDoctor];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tbl_groups.delegate = self;
            self.tbl_groups.dataSource = self;
            [self.tbl_groups reloadData];
        });
        
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
- (IBAction)onAddNew:(id)sender {
    NewMessageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NewMessageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return allChannels.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject * channel = [allChannels objectAtIndex:indexPath.row];
    BOOL isGroup = [channel[PARSE_ROOM_ISGROUP] boolValue];
    if(isGroup) return 65;
    return 85;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject * channel = [allChannels objectAtIndex:indexPath.row];
    BOOL isGroup = [channel[PARSE_ROOM_ISGROUP] boolValue];
    if(isGroup){
        static NSString *cellIdentifier = @"GroupMessageTableViewCell";
        GroupMessageTableViewCell *cell = (GroupMessageTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.delegate = self;
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:221.f/255.0f green:65.f/255.0f blue:65.f/255.0f alpha:1.0f]]];
            cell.rightButtons[0].tag = indexPath.row;
            cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
            cell.rightExpansion.expansionLayout = MGSwipeExpansionLayoutCenter;
            cell.rightExpansion.buttonIndex = 1;
            
            PFObject * channel = [allChannels objectAtIndex:indexPath.row];
            cell.lbl_groupName.text = channel[PARSE_ROOM_GROUPNAME];
            PFObject * lastMessage = channel[PARSE_ROOM_LAST_MESSAGE];
            if(lastMessage){
                cell.lbl_lastMessage.text = lastMessage[PARSE_HISTORY_MESSAGE];
            }else{
                cell.lbl_lastMessage.text = @"";
            }
        }
        return cell;
    }else{
        static NSString *cellIdentifier = @"UserMessageTableViewCell";
        UserMessageTableViewCell *cell = (UserMessageTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.delegate = self;
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:221.f/255.0f green:65.f/255.0f blue:65.f/255.0f alpha:1.0f]]];
            cell.rightButtons[0].tag = indexPath.row;
            cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
            cell.rightExpansion.expansionLayout = MGSwipeExpansionLayoutCenter;
            cell.rightExpansion.buttonIndex = 1;
            
            PFObject * channel = [allChannels objectAtIndex:indexPath.row];
            NSMutableArray * recipers = channel[PARSE_ROOM_PARTICIPANTS];
            PFUser * target = [recipers firstObject];
            if([target.objectId isEqualToString:[PFUser currentUser].objectId]){
                target = [recipers lastObject];
            }
            [Util setImage:cell.img_userThumb imgFile:(PFFile *)target[PARSE_USER_AVATAR] withDefault:[UIImage imageNamed:@"ic_default_avatar"]];
            cell.lbl_doctorName.text = [NSString stringWithFormat:@"Dr. %@ %@", target[PARSE_USER_FIRSTNAME], target[PARSE_USER_LASTSTNAME]];
            cell.lbl_patientInfo.layer.cornerRadius = 5.f;
            PFObject * patientObj = channel[PARSE_ROOM_PATIENT];
            [cell setPatientInfo:[NSString stringWithFormat:@"%@-%@ %@", patientObj[PARSE_PATIENTS_RECORDNUMBER], patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]]];
            PFObject * lastMessage = channel[PARSE_ROOM_LAST_MESSAGE];
            if(lastMessage){
                cell.lbl_lastMessage.text = lastMessage[PARSE_HISTORY_MESSAGE];
            }else{
                cell.lbl_lastMessage.text = @"";
            }
            
        }
        return cell;
    }
    return nil;
}
- (BOOL) swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    int row = (int)[self.tbl_groups indexPathForCell:cell].row;
    if(direction == MGSwipeDirectionRightToLeft){
        NSString *msg = @"Are you sure delete this message?";
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            PFObject * channel = [allChannels objectAtIndex:row];
            NSMutableArray * deletedUsers = channel[PARSE_ROOM_DELETEUSER];
            if(!deletedUsers || deletedUsers.count == 0)
                deletedUsers = [NSMutableArray new];
            [deletedUsers addObject:[PFUser currentUser]];
            [self showLoadingBar];
            channel[PARSE_ROOM_DELETEUSER] = deletedUsers;
            [channel saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self hideLoadingBar];
                [self fetchData];
            }];
            
        }];
        [alert addButton:@"No" actionBlock:^(void) {
        }];
        [alert showError:@"Delete" subTitle:msg closeButtonTitle:nil duration:0.0f];
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject * channel = [allChannels objectAtIndex:indexPath.row];
    BOOL isGroup = [channel[PARSE_ROOM_ISGROUP] boolValue];
    
    ChattingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChattingViewController"];
    controller.mesageChannelInfo = channel;
    if(!isGroup){
        NSMutableArray * recipers = channel[PARSE_ROOM_PARTICIPANTS];
        PFUser * target = [recipers firstObject];
        if([target.objectId isEqualToString:[PFUser currentUser].objectId]){
            target = [recipers lastObject];
        }
        controller.mesageReceiverInfo = target;
        PFObject * patientObj = channel[PARSE_ROOM_PATIENT];
        controller.linkedPatientInfo = patientObj;
    }
    [self.navigationController pushViewController:controller animated:YES];
}
@end
