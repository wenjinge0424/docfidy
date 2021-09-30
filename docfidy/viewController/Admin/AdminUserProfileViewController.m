//
//  AdminUserProfileViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminUserProfileViewController.h"

@interface AdminUserProfileViewController ()
@property (weak, nonatomic) IBOutlet CircleImageView *img_thumb;
@property (weak, nonatomic) IBOutlet UITextField *edt_name;
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UITextField *edt_password;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;

@end

@implementation AdminUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Util setImage:self.img_thumb imgFile:(PFFile *)self.user[PARSE_USER_AVATAR] withDefault:[UIImage imageNamed:@"ic_default_avatar"]];
    self.edt_name.text = [NSString stringWithFormat:@"%@ %@", self.user[PARSE_USER_FIRSTNAME], self.user[PARSE_USER_LASTSTNAME]];
    self.edt_email.text = self.user[PARSE_USER_NAME];
    self.edt_password.text = self.user[PARSE_USER_PREVIEWPWD];
    self.lbl_userName.text = self.edt_name.text;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onRemoveUser:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"CANCEL" actionBlock:^(void) {
    }];
    [alert addButton:@"REMOVE" actionBlock:^(void) {
        BOOL isBanned = [self.user[PARSE_USER_IS_BANNED] boolValue];
        NSString * msg = @"This user removed.";
        [self showLoadingBar];
        [PFUser logOutInBackgroundWithBlock:^(NSError *error){
            if (error){
                [self hideLoadingBar];
                [Util showAlertTitle:self title:@"Logout" message:[error localizedDescription]];
            } else {
                [Util setLoginUserName:@"" password:@""];
                NSString * userEmail = self.user[PARSE_USER_NAME];
                NSString * userPasswrod = self.user[PARSE_USER_PREVIEWPWD];
                
                [PFUser logInWithUsernameInBackground:userEmail password:userPasswrod block:^(PFUser *user, NSError *error) {
                    if (user) {
                        user[PARSE_USER_IS_BANNED] = [NSNumber numberWithBool:!isBanned];
                        [user saveInBackgroundWithBlock:^(BOOL success, NSError* error){
                            if(!success){
                                [self hideLoadingBar];
                                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                            }else{
                                [PFUser logOutInBackgroundWithBlock:^(NSError *error){
                                    if (error){
                                        [self hideLoadingBar];
                                        [Util showAlertTitle:self title:@"Logout" message:[error localizedDescription]];
                                    } else {
                                        NSString * adminName = [Util getAdminName];
                                        NSString * adminPwd = [Util getAdminPassword];
                                        [PFUser logInWithUsernameInBackground:adminName password:adminPwd block:^(PFUser *user, NSError *error) {
                                            [self hideLoadingBar];
                                            
                                            if(!isBanned){
                                                [Util sendPushNotification:userEmail message:[NSString stringWithFormat:@"App admin banned your account."] type:2];
                                            }
                                            
                                            [Util setLoginUserName:adminName password:adminPwd];
                                            [Util showAlertTitle:self title:@"Success" message:msg finish:^{
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                                        }];
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }];
    }];
    [alert showError:@"Remove user?" subTitle:@"Are you sure you want to remove this user?" closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
