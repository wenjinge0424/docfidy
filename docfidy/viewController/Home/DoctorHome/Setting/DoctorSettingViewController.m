//
//  DoctorSettingViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorSettingViewController.h"
#import "LoginViewController.h"
#import "DoctoProfileViewController.h"
#import "AboutAppViewController.h"
#import "WebPageViewController.h"
#import "SignUpPatternViewController.h"

@interface DoctorSettingViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation DoctorSettingViewController

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
    DoctoProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctoProfileViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onUnlockPatter:(id)sender {
    SignUpPatternViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpPatternViewController"];
    controller.runType = RUN_TYPE_SETTING;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onRateApp:(id)sender {
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1362913603"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [appDelegate checkTDBRate];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showInfo:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onSendFeedBack:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@""];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"support@docfidy.com"]];
        [mailCont setMessageBody:@"" isHTML:NO];
        
        [self presentModalViewController:mailCont animated:YES];
    }else{
        [Util showAlertTitle:self title:@"Error" message:@"You can't send email with this device. Please config your mail account first."];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)onAboutApp:(id)sender {
    AboutAppViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutAppViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onPrivacyPolicy:(id)sender {
    WebPageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebPageViewController"];
    controller.runMode = 0;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onterms:(id)sender {
    WebPageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WebPageViewController"];
    controller.runMode = 1;
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
