//
//  DoctorMacrocodeViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorMacrocodeViewController.h"

@interface DoctorMacrocodeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *edt_billCode;
@property (weak, nonatomic) IBOutlet UITextField *edt_billAmount;

@end

@implementation DoctorMacrocodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_billCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_billCode.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_billAmount.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_billAmount.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
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
- (IBAction)onSave:(id)sender {
    if(self.edt_billCode.text.length ==  0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter bill code."];
        return;
    }
    if(self.edt_billAmount.text.length ==  0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter bill amount."];
        return;
    }
    if(self.edt_billCode.text.length >=  10){
        [Util showAlertTitle:self title:@"Error" message:@"Bill code length is too long."];
        return;
    }
    if(self.edt_billAmount.text.length >=  10){
        [Util showAlertTitle:self title:@"Error" message:@"Bill amount length is too long."];
        return;
    }
    [self showLoadingBar];
    for(PFObject * patientObj in self.patientArray){
        PFObject * billingObj = [PFObject objectWithClassName:PARSE_TABLE_BILLING];
        billingObj[PARSE_BILLING_OWNER] = [PFUser currentUser];
        billingObj[PARSE_BILLING_PATIENT] = patientObj;
        billingObj[PARSE_BILLING_SUBMITTED] = [NSNumber numberWithBool:NO];
        billingObj[PARSE_BILLING_CODE] = self.edt_billCode.text;
        billingObj[PARSE_BILLING_AMOUNT] = [NSNumber numberWithInt:[self.edt_billAmount.text intValue]];
        [billingObj saveInBackground];
    }
    [self hideLoadingBar];
    [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
