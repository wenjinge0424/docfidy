//
//  AdminSettingViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminSettingViewController.h"
#import "AdminEditProfileViewController.h"
#import "LoginViewController.h"

@interface AdminSettingViewController ()

@end

@implementation AdminSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
- (IBAction)onEditProfile:(id)sender {
    AdminEditProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminEditProfileViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onLogOut:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Cancel" actionBlock:^(void) {
    }];
    [alert addButton:@"Ok" actionBlock:^(void) {
        [self showLoadingBar];
        [PFUser logOutInBackgroundWithBlock:^(NSError *error){
            [self hideLoadingBar];
            if (error){
                [Util showAlertTitle:self title:@"Logout" message:[error localizedDescription]];
            } else {
                [Util setLoginUserName:@"" password:@""];
                
                UIViewController * targetCtr = nil;
                for(UIViewController * ctr in self.navigationController.viewControllers){
                    if([ctr isKindOfClass:[LoginViewController class]]){
                        targetCtr = ctr;
                    }
                }
                if(targetCtr){
                    [self.navigationController popToViewController:targetCtr animated:YES];
                }
                
            }
        }];
    }];
    [alert showError:@"Logout" subTitle:@"Are you sure you want to logout?" closeButtonTitle:nil duration:0.0f];
}

@end
