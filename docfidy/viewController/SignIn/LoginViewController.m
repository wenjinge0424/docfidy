//
//  LoginViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgotPwdViewController.h"
#import "SignUpTypeViewController.h"
#import "AdminMenuViewController.h"
#import "DoctorHomeViewController.h"
#import "NurseHomeViewController.h"
#import "ClientHomeViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UITextField *edt_password;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_password.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Util getLoginUserName].length > 0 && [Util getLoginUserPassword].length > 0){
        _edt_email.text = [Util getLoginUserName];
        _edt_password.text = [Util getLoginUserPassword];
        [self onLogin:nil];
    }else{

    }
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _edt_email.text = @"";
    _edt_password.text = @"";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    NSString *password = _edt_password.text;
    NSString * errorMsg = @"";
    if (email.length == 0){
        errorMsg = @"Please input your email.";
    }else if(![email isEmail]){
        errorMsg = @"Please input valid email.";
    }else if([email containsString:@".."]){
        errorMsg = @"Please input valid email.";
    }else if (password.length == 0){
        errorMsg = @"Please input your password.";
    }
    if(errorMsg.length > 0){
        [Util showAlertTitle:self title:@"Sign In" message:errorMsg];
        return NO;
    }
    return YES;
}
- (IBAction)onLogin:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if (![self isValid]){
        return;
    }
    [_edt_email resignFirstResponder];
    [_edt_password resignFirstResponder];
    
    [self showLoadingBar];
    PFQuery *query = [PFUser query];
    [query whereKey:PARSE_USER_EMAIL equalTo:_edt_email.text.lowercaseString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error && object) {
            PFUser *user = (PFUser *)object;
            NSString *username = user.username;
            [PFUser logInWithUsernameInBackground:username password:_edt_password.text block:^(PFUser *user, NSError *error) {
                [self hideLoadingBar];
                if (user) {
                    BOOL isBanned = [user[PARSE_USER_IS_BANNED] boolValue];
                    if (isBanned){
                        [Util showAlertTitle:self title:@"Error" message:@"Banned User"];
                        return;
                    }
                    int userType = [user[PARSE_USER_TYPE] intValue];
                    [Util setLoginUserName:user.email password:_edt_password.text];
                    [Util setUnlockPattern:user[PARSE_USER_PATTERN]];
                    [self gotoMainScreen];
                    if(userType == 400){//admin
                        [Util setAdminNameAndPassword:user.email :_edt_password.text];
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
                } else {
                    NSString *errorString = @"Password entered is incorrect.";
                    [Util showAlertTitle:self title:@"Login Failed" message:errorString finish:^{
                        [_edt_password becomeFirstResponder];
                    }];
                }
            }];
        } else {
            [self hideLoadingBar];
            [Util setLoginUserName:@"" password:@""];
            
            NSString *msg = @"Email entered is not registered. Create an account now?";
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.customViewColor = MAIN_COLOR;
            alert.horizontalButtons = YES;
            [alert addButton:@"Not now" actionBlock:^(void) {
            }];
            [alert addButton:@"Sign Up" actionBlock:^(void) {
                [self onAskToAdmin:nil];
            }];
            [alert showError:@"Unregistered Mail" subTitle:msg closeButtonTitle:nil duration:0.0f];
        }
    }];
}
- (void) gotoMainScreen
{
//    MenuViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MenuViewController"];
//    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onForgotPassword:(id)sender {
    ForgotPwdViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPwdViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onAskToAdmin:(id)sender {
    SignUpTypeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpTypeViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
