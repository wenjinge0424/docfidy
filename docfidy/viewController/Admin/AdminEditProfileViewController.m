//
//  AdminEditProfileViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminEditProfileViewController.h"

@interface AdminEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UITextField *edt_password;
@property (weak, nonatomic) IBOutlet UITextField *edt_confirm;

@end

@implementation AdminEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_password.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_confirm.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_confirm.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    [self showLoadingBar];
    PFUser * me = [PFUser currentUser];
    [me fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [self hideLoadingBar];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.edt_email.text = me[PARSE_USER_EMAIL];
            self.edt_password.text = me[PARSE_USER_PREVIEWPWD];
            self.edt_confirm.text = me[PARSE_USER_PREVIEWPWD];
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
- (IBAction)saveChange:(id)sender {
    PFUser * me = [PFUser currentUser];
    NSString * password = self.edt_password.text;
    NSString * recentPassword = me[PARSE_USER_PREVIEWPWD];
    if(password.length < 6 || password.length > 20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"We detected an error. Help me review your answer and try again." finish:^(void) {
            [self.edt_password becomeFirstResponder];
        }];
    }else if(self.edt_confirm.text.length < 6 || self.edt_confirm.text.length > 20){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"We detected an error. Help me review your answer and try again." finish:^(void) {
            [self.edt_password becomeFirstResponder];
        }];
    }else if(![self.edt_confirm.text isEqualToString:password]){
        [Util showAlertTitle:self title:@"Edit Profile" message:@"We detected an error. Help me review your answer and try again." finish:^(void) {
            [self.edt_confirm becomeFirstResponder];
        }];
    }else{
        me.password = password;
        me[PARSE_USER_PREVIEWPWD] = password;
        [self showLoadingBar];
        [me saveInBackgroundWithBlock:^(BOOL success, NSError * error){
            [PFUser logInWithUsernameInBackground:me.email password:me.password block:^(PFObject *object, NSError *error){
                [self hideLoadingBar];
                if(!error){
                    [Util showAlertTitle:self title:@"Success" message:@"Your profile successfully changed."];
                }else{
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                }
            }];
        }];
    }
}
@end
