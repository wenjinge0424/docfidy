//
//  SignUpPatternViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpPatternViewController.h"
#import "ioPatternLock.h"
#import "AdminMenuViewController.h"
#import "DoctorHomeViewController.h"
#import "NurseHomeViewController.h"
#import "ClientHomeViewController.h"

@interface SignUpPatternViewController ()<IOPatternLockDelegate>
@property (weak, nonatomic) IBOutlet UIView *view_actionContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;

@end

@implementation SignUpPatternViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.runType == RUN_TYPE_SIGNUP){
        self.lbl_title.text = @"Sign Up";
    }else{
        self.lbl_title.text = @"Edit Unlock Pattern";
    }
    
    IOPatternLockView * actionView = [[IOPatternLockView alloc] initWithFrame:self.view_actionContainer.bounds];
    actionView.column = 3;
    actionView.row = 3;
    actionView.minimumNumberOfSelections = 2;
    actionView.circleSpace = 20;
    actionView.innerCirclePadding = 15;
    actionView.lineWidth = 4;
    actionView.delegate = self;
    actionView.backgroundColor = [UIColor whiteColor];
    actionView.borderColor = [UIColor lightGrayColor];
    actionView.innerCircleColor = [UIColor lightGrayColor];
    actionView.lineColor = [UIColor darkGrayColor];
    actionView.activeBorderColor = [UIColor blackColor];
    actionView.activeInnerCircleColor = [UIColor blackColor];
    [self.view_actionContainer addSubview:actionView];
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
- (NSString*) convertToString:(NSArray<NSNumber *> *)selectedPatterns
{
    NSString * string = @"[";
    for(NSNumber* subNum in selectedPatterns){
        string = [string stringByAppendingFormat:@"%@-", [subNum stringValue]];
    }
    string = [string substringToIndex:string.length - 1];
    string = [string stringByAppendingFormat:@"]"];
    return string;
}
- (void)ioPatternLockView:(IOPatternLockView *)patternLockView patternCompleted:(NSArray<NSNumber *> *)selectedPatterns
{
    if(self.runType == RUN_TYPE_SIGNUP){
        self.user[PARSE_USER_PATTERN] = [self convertToString:selectedPatterns];
        [self showLoadingBar];
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [Util setLoginUserName:self.user.username password:self.user.password];
                [Util setUnlockPattern:self.user[PARSE_USER_PATTERN]];
                
                PFQuery *query = [PFQuery  queryWithClassName:PARSE_TABLE_INVITE];
                [query whereKey:PARSE_INVITE_TYPE equalTo:self.user[PARSE_USER_TYPE]];
                [query whereKey:PARSE_INVITE_EMAIL equalTo:self.user[PARSE_USER_EMAIL]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                    [self hideLoadingBar];
                    if (error){
                        [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                    } else {
                        for (int i=0;i<array.count;i++){
                            PFObject *owner = [array objectAtIndex:i];
                            [owner deleteInBackground];
                        }
                        int userType = [self.user[PARSE_USER_TYPE] intValue];
                        if(userType == 400){//admin
                            AdminMenuViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminMenuViewController"];
                            [self.navigationController pushViewController:controller animated:YES];
                            return;
                        }else if(userType == 200){//doctor
                            DoctorHomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorHomeViewController"];
                            [self.navigationController pushViewController:controller animated:YES];
                            return;
                        }else if(userType == 100){//nurse
                            NurseHomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NurseHomeViewController"];
                            [self.navigationController pushViewController:controller animated:YES];
                            return;
                        }else if(userType == 300){//client
                            ClientHomeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ClientHomeViewController"];
                            [self.navigationController pushViewController:controller animated:YES];
                            return;
                        }
                    }
                }];
            } else {
                [self hideLoadingBar];
                NSString *message = [error localizedDescription];
                [Util showAlertTitle:self title:@"Error" message:message];
            }
        }];
    }else{
        PFUser * me = [PFUser currentUser];
        NSString * patternStr = [self convertToString:selectedPatterns];
        me[PARSE_USER_PATTERN] = patternStr;
        [self showLoadingBar];
        [me saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    }
}
- (void)ioPatternLockView:(IOPatternLockView *)patternLockView patternCompletedWithError:(NSError *)error
{
    
}
@end
