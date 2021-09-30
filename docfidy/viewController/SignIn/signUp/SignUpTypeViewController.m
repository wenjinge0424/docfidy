//
//  SignUpTypeViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpTypeViewController.h"
#import "SignUpEmailViewController.h"

@interface SignUpTypeViewController ()
{
    PFUser *user;
}
@end

@implementation SignUpTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [PFUser user];
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
- (IBAction)onDoctor:(id)sender {
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:200];
    SignUpEmailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpEmailViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onNurse:(id)sender {
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:100];
    SignUpEmailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpEmailViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onUser:(id)sender {
    user[PARSE_USER_TYPE] = [NSNumber numberWithInt:300];
    SignUpEmailViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpEmailViewController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
