//
//  NurseMainMenuViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/31/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "NurseMainMenuViewController.h"
#import "AdminScheduleViewController.h"
#import "DoctorSettingViewController.h"

@interface NurseMainMenuViewController ()

@end

@implementation NurseMainMenuViewController

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
- (IBAction)onPatients:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSchedule:(id)sender {
    AdminScheduleViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminScheduleViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSetting:(id)sender {
    DoctorSettingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorSettingViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
