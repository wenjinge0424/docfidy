//
//  DoctorMainMenuViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorMainMenuViewController.h"
#import "DoctorBillingViewController.h"
#import "AdminScheduleViewController.h"
#import "DoctorSettingViewController.h"
#import "DistribViewController.h"
#import "MessageViewController.h"

@interface DoctorMainMenuViewController ()
{
    PFUser * me;
}
@property (weak, nonatomic) IBOutlet UIImageView *img_disturb;
@end

@implementation DoctorMainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showLoadingBar];
    [me fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        me = [PFUser currentUser];
        [self hideLoadingBar];
        BOOL isDiscribe = [me[PARSE_USER_DONOTDISCRIB] boolValue];
        if(isDiscribe){
            [self.img_disturb setImage:[UIImage imageNamed:@"ic_not_disturb_off"]];
        }else{
            [self.img_disturb setImage:[UIImage imageNamed:@"ic_not_disturb"]];
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
- (IBAction)onPatients:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onMessage:(id)sender {
    MessageViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MessageViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onBilling:(id)sender {
    DoctorBillingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorBillingViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSchedule:(id)sender {
    AdminScheduleViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminScheduleViewController"];
    controller.runTypeDoctor = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSetting:(id)sender {
    DoctorSettingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DoctorSettingViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onDisturb:(id)sender {
    DistribViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DistribViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
