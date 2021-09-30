//
//  EditBillingViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/17/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "EditBillingViewController.h"
#import "CustomTableViewCell.h"
#import "SelectStringViewController.h"

@interface EditBillingViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SelectStringViewControllerDelegate>
{
    NSMutableArray * codeList;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;

@end

@implementation EditBillingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    codeList = [NSMutableArray new];
    codeList = self.patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
    if(!self.billObject){
        self.billObject = [PFObject objectWithClassName:PARSE_TABLE_BILLING];
    }
    [self reloadData];
}
- (void) reloadData
{
    self.tbl_data.delegate = self;
    self.tbl_data.dataSource = self;
    [self.tbl_data reloadData];
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
- (IBAction)onAdd:(id)sender {
    NSString * lastcode = [codeList lastObject];
    if([lastcode isEqualToString:@""]){
        [codeList removeLastObject];
    }
    if(codeList.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter diagnosis code."];
        return;
    }
    if(!self.billObject[PARSE_BILLING_CODE] || [self.billObject[PARSE_BILLING_CODE] isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter bill code."];
        return;
    }
    if(!self.billObject[PARSE_BILLING_AMOUNT]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter bill amount."];
        return;
    }
    self.billObject[PARSE_BILLING_OWNER] = [PFUser currentUser];
    self.billObject[PARSE_BILLING_PATIENT] = self.patientObj;
    self.billObject[PARSE_BILLING_SUBMITTED] = [NSNumber numberWithBool:NO];
    [self showLoadingBar];
    self.patientObj[PARSE_PATIENTS_DIAGNOSISCODE] = codeList;
    [self.patientObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }else{
            [self.billObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error){
                    [self hideLoadingBar];
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                }else{
                    [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return codeList.count + 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (void) setTextFieldPlaceHolder:(NSString*) str toTextField:(UITextField*) view
{
    view.placeholder = str;
    view.attributedPlaceholder = [[NSAttributedString alloc] initWithString:view.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < codeList.count){
        static NSString *cellIdentifier = @"TextEditCell";
        TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            [self setTextFieldPlaceHolder:@"Diagnosis code" toTextField:cell.edt_text];
            [cell.edt_text setKeyboardType:UIKeyboardTypeDefault];
            cell.edt_text.text = [codeList objectAtIndex:indexPath.row];
            cell.btn_action.tag = indexPath.row;
            cell.btn_action.hidden = NO;
            [cell.btn_action addTarget:self action:@selector(onSelectDiagnosisCode:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else if(indexPath.row == codeList.count){
        static NSString *cellIdentifier = @"RightCornerButtonCell";
        RightCornerButtonCell *cell = (RightCornerButtonCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.btn_action.tag = 1;
            [cell.btn_action addTarget:self action:@selector(onAddMoreDiagnosisCode:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else if(indexPath.row == codeList.count + 1){
        static NSString *cellIdentifier = @"TextEditCell";
        TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.edt_text.tag = 0;
            [self setTextFieldPlaceHolder:@"Bill code" toTextField:cell.edt_text];
            [cell.edt_text setKeyboardType:UIKeyboardTypeNumberPad];
            cell.edt_text.delegate = self;
            cell.btn_action.hidden = YES;
            cell.edt_text.text = [self getDataWithTag:0];
        }
        return cell;
    }else if(indexPath.row == codeList.count + 2){
        static NSString *cellIdentifier = @"TextEditCell";
        TextEditCell *cell = (TextEditCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
        if(cell){
            cell.edt_text.tag = 1;
            [self setTextFieldPlaceHolder:@"Bill amount" toTextField:cell.edt_text];
            [cell.edt_text setKeyboardType:UIKeyboardTypeNumberPad];
            cell.edt_text.delegate = self;
            cell.btn_action.hidden = YES;
            cell.edt_text.text = [self getDataWithTag:1];
        }
        return cell;
    }
    return nil;
}
- (void) onSelectDiagnosisCode:(UIButton*)button
{
    SelectStringViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectStringViewController"];
    controller.stringArray = [[CSVUtil new] getDiagnosisCodes];
    controller.ExceptionArray = codeList;
    controller.ctrolIndex = (int)button.tag;
    controller.delegate = self;
    BIZPopupViewController *popUp = [[BIZPopupViewController alloc] initWithContentViewController:controller contentSize:CGSizeMake(320, 400)];
    controller.parent = popUp;
    [self.navigationController presentViewController:popUp animated:YES completion:nil];
}
- (void)stringSelected:(NSString *)str withTag:(int)tag
{
    int buttonIndex = tag;
    if(codeList.count <= buttonIndex)
        return;
    [codeList replaceObjectAtIndex:buttonIndex withObject:str];
    [self reloadData];
}
- (void) onAddMoreDiagnosisCode:(UIButton*)button
{
    NSString * lastItem = [codeList lastObject];
    if([lastItem isEqualToString:@""]){
        [Util showAlertTitle:self title:@"Error" message:@"Please enter diagnosis code."];
        return;
    }
    [codeList addObject:@""];
    [self reloadData];
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self setDataWithTag:(int)textField.tag withData:textField.text];
}
- (void) setDataWithTag:(int)tag withData:(NSString*)data
{
    if(tag == 0){// bill code
        self.billObject[PARSE_BILLING_CODE] = data;
    }else if(tag == 1){// bill amount
        self.billObject[PARSE_BILLING_AMOUNT] = [NSNumber numberWithInt:[data intValue]];
    }
}
- (NSString*) getDataWithTag:(int)tag
{
    if(tag == 0){// bill code
        return self.billObject[PARSE_BILLING_CODE];
    }else if(tag == 1){// bill amount
        return [self.billObject[PARSE_BILLING_AMOUNT] stringValue];
    }
    return @"";
}

@end
