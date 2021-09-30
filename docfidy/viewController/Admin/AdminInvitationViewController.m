//
//  AdminInvitationViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminInvitationViewController.h"

@interface AdminInvitationViewController ()
{
    NSMutableArray * dataArray;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UILabel *lbl_desc;

@end

@implementation AdminInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.viewType == VIEW_TYPE_DOCTOR){
        self.lbl_title.text = @"Invite Doctors";
        self.lbl_desc.text = @"Please enter email address to invite Doctor";
    }else if(self.viewType == VIEW_TYPE_NURSE){
        self.lbl_title.text = @"Invite Nurses";
        self.lbl_desc.text = @"Please enter email address to invite Nurse";
    }else if(self.viewType == VIEW_TYPE_PERSON){
        self.lbl_title.text = @"Invite Other Health Professionals";
        self.lbl_desc.text = @"Please enter email address to invite Other Health Professional";
    }
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    [self fetchData];
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [self showLoadingBar];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_INVITE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFObject  *owner = [array objectAtIndex:i];
                [dataArray addObject:owner];
            }
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
- (PFObject *) getActiveItem:(NSString*)email
{
    for(PFObject * item in dataArray){
        NSString * _email = item[PARSE_INVITE_EMAIL];
        if([_email isEqualToString:email]){
            return item;
        }
    }
    PFObject * inviteObject = [PFObject objectWithClassName:PARSE_TABLE_INVITE];
    inviteObject[PARSE_INVITE_EMAIL] = email;
    inviteObject[PARSE_INVITE_PASSWROD] = @"docfidy123";
    return inviteObject;
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSendInvitation:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if (![self isValid]){
        return;
    }
    PFObject * inviteObj = [self getActiveItem:_edt_email.text];
    inviteObj[PARSE_INVITE_TYPE] = [NSNumber numberWithInt:100];
    if(self.viewType == VIEW_TYPE_DOCTOR){
        inviteObj[PARSE_INVITE_TYPE] = [NSNumber numberWithInt:200];
    }else if(self.viewType == VIEW_TYPE_NURSE){
        inviteObj[PARSE_INVITE_TYPE] = [NSNumber numberWithInt:100];
    }else if(self.viewType == VIEW_TYPE_PERSON){
        inviteObj[PARSE_INVITE_TYPE] = [NSNumber numberWithInt:300];
    }
    [self showLoadingBar];
    [inviteObj saveInBackgroundWithBlock:^(BOOL success, NSError * error){
        [self hideLoadingBar];
        [Util showAlertTitle:self title:@"Success" message:@"Invite is success." finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    NSString * errorMsg = @"";
    if (email.length == 0){
        errorMsg = @"Please input your email.";
    }else if(![email isEmail]){
        errorMsg = @"Please input valid email.";
    }else if([email containsString:@".."]){
        errorMsg = @"Please input valid email.";
    }
    if(errorMsg.length > 0){
        [Util showAlertTitle:self title:@"Invite" message:errorMsg];
        return NO;
    }
    return YES;
}
@end
