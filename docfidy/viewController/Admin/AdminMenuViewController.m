//
//  AdminMenuViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/27/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminMenuViewController.h"
#import "AdminUserListViewController.h"
#import "AdminPatientsListViewController.h"
#import "AdminBillCodeViewController.h"
#import "AdminScheduleViewController.h"
#import "AdminSettingViewController.h"
@interface AdminMenuViewController ()

@end

@implementation AdminMenuViewController

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
- (IBAction)onDoctors:(id)sender {
    AdminUserListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminUserListViewController"];
    controller.viewType = VIEW_TYPE_DOCTOR;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onNurses:(id)sender {
    AdminUserListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminUserListViewController"];
    controller.viewType = VIEW_TYPE_NURSE;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onPatients:(id)sender {
    AdminPatientsListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminPatientsListViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onProfessionals:(id)sender {
    AdminUserListViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminUserListViewController"];
    controller.viewType = VIEW_TYPE_PERSON;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onBillingCode:(id)sender {
    AdminBillCodeViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminBillCodeViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onScheduling:(id)sender {
    AdminScheduleViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminScheduleViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSetting:(id)sender {
    AdminSettingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminSettingViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
