//
//  DistribViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/31/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DistribViewController.h"

@interface DistribViewController ()
{
    PFUser * me;
    NSMutableArray * allUsers;
}
@property (weak, nonatomic) IBOutlet UITextView * edt_note;
@property (weak, nonatomic) IBOutlet UISwitch *switch_disturb;
@end

@implementation DistribViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_note.layer.cornerRadius = 5.f;
    
    me = [PFUser currentUser];
    [self hideLoadingBar];
    BOOL isDiscribe = [me[PARSE_USER_DONOTDISCRIB] boolValue];
    if(isDiscribe){
        [self.switch_disturb setOn:YES];
    }else{
        [self.switch_disturb setOn:NO];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showLoadingBar];
    PFQuery * userQuery = [PFUser query];
    [userQuery whereKey:PARSE_FIELD_OBJECT_ID notEqualTo:[PFUser currentUser].objectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            allUsers = [[NSMutableArray alloc] initWithArray:array];
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
- (IBAction)onSave:(id)sender {
    if(self.edt_note.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input message."];
        return;
    }
    [self showLoadingBar];
    me[PARSE_USER_DONOTDISCRIB] = [NSNumber numberWithBool:self.switch_disturb.isOn];
    [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            
            for(PFUser * user in allUsers){
                NSString * pushMsg = [NSString stringWithFormat:@"%@ %@ change disturb state. '%@'", me[PARSE_USER_FIRSTNAME], me[PARSE_USER_LASTSTNAME], self.edt_note.text];//self.edt_note.text;
                NSDictionary *data = @{
                                       @"alert" : pushMsg,
                                       @"badge" : @"Increment",
                                       @"sound" : @"cheering.caf",
                                       @"email" : user.username,
                                       @"type"  : [NSNumber numberWithInt:PUSH_TYPE_DISTRIBE],
                                       @"data"  : @""
                                       };
                
                [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
                    if (err) {
                        NSLog(@"Fail APNS: %@", @"SendChat");
                    } else {
                        NSLog(@"Success APNS: %@", @"SendChat");
                    }
                }];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}
@end
