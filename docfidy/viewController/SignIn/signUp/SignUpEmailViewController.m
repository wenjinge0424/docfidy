//
//  SignUpEmailViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpEmailViewController.h"
#import "SingUpPWDViewController.h"

@interface SignUpEmailViewController ()
{
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_valid;
@property (weak, nonatomic) IBOutlet UIButton *btn_noUse;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@end

@implementation SignUpEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    [_edt_email addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [self showLoadingBar];
    PFQuery *query = [PFQuery  queryWithClassName:PARSE_TABLE_INVITE];
    [query whereKey:PARSE_INVITE_TYPE equalTo:self.user[PARSE_USER_TYPE]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFObject *owner = [array objectAtIndex:i];
                [dataArray addObject:owner[PARSE_INVITE_EMAIL]];
            }
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    NSString * email = _edt_email.text;
    if (![dataArray containsObject:email]){
        NSString * error = @"";
        if([self.user[PARSE_USER_TYPE] intValue] == 200){
            error = @"Entered email address is not invited as doctor. Please contact administrator.";
        }else if([self.user[PARSE_USER_TYPE] intValue] == 100){
            error = @"Entered email address is not invited as nurse. Please contact administrator.";
        }else if([self.user[PARSE_USER_TYPE] intValue] == 300){
            error = @"Entered email address is not invited as other health professionals. Please contact administrator.";
        }
        [Util showAlertTitle:self title:@"Error" message:error];
        return;
    }
    self.user[PARSE_USER_EMAIL] = _edt_email.text;
    self.user[PARSE_USER_IS_BANNED] = [NSNumber numberWithBool:NO];
    self.user[PARSE_USER_IS_PAID] = [NSNumber numberWithBool:YES];
    self.user.username = _edt_email.text;
    SingUpPWDViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SingUpPWDViewController"];
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    _edt_email.text = [Util trim:_edt_email.text];
    NSString *email = _edt_email.text;
    if (email.length == 0){
        return NO;
    }
    if (![email isEmail]){
        return NO;
    }
    return YES;
}
-(void)textFieldDidChange :(UITextField *) textField{
    _edt_email.text = [Util trim:_edt_email.text.lowercaseString];
    NSString *email = _edt_email.text;
    _btn_valid.selected = [email isEmail];
    if (![email isEmail]){
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([email containsString:@".."]){
        _btn_valid.selected = NO;
        _btn_noUse.selected = NO;
        _btn_next.enabled = NO;
        return;
    }
    if ([email isEmail]){
        _btn_valid.selected = YES;
        _btn_noUse.selected = YES;
        _btn_next.enabled = YES;
    }
}
@end
