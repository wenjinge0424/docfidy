//
//  AdminBillCodeViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminBillCodeViewController.h"
#import "BillingCollectionViewCell.h"
#import "AdminBillingCollectionViewController.h"

@interface AdminBillCodeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>
{
    int selectedType;
    
    NSMutableArray * allUsers;
    NSMutableArray * billings;
    
    NSMutableArray * searchedBillings;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_current;
@property (weak, nonatomic) IBOutlet UIButton *btn_dischage;
@property (weak, nonatomic) IBOutlet UITextField *edt_search;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation AdminBillCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedType = 0;
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_search.delegate = self;
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (void) fetchData
{
    allUsers = [NSMutableArray new];
    billings = [NSMutableArray new];
    [self showLoadingBar];
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [allUsers addObject:owner];
            }
            PFQuery * billingQuery = [PFQuery queryWithClassName:PARSE_TABLE_BILLING];
            [billingQuery includeKey:PARSE_BILLING_PATIENT];
            [billingQuery includeKey:PARSE_BILLING_OWNER];
            if(selectedType == 1){
                [billingQuery whereKey:PARSE_BILLING_PAYMENTCOMPLETE equalTo:[NSNumber numberWithBool:YES]];
            }else
            {
                [billingQuery whereKey:PARSE_BILLING_PAYMENTCOMPLETE notEqualTo:[NSNumber numberWithBool:YES]];
            }
            [billingQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
                [self hideLoadingBar];
                if (error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                } else {
                    for (int i=0;i<array.count;i++){
                        PFObject * owner = [array objectAtIndex:i];
                        [billings addObject:owner];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self reloadTableWithSearchKey:self.edt_search.text];
                    });
                }
            }];
        }
    }];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadTableWithSearchKey:searchStr];
    return YES;
}
- (void) reloadTableWithSearchKey:(NSString*)searchKey
{
    searchedBillings = [NSMutableArray new];
    for(PFObject * billingObj in billings){
        if([self searchBillingInfoWithSearchKey:searchKey withObject:billingObj]){
            [searchedBillings addObject:billingObj];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    });
}
- (BOOL) searchBillingInfoWithSearchKey:(NSString*) searchKey withObject:(PFObject*)billingObj
{
    if([searchKey isEqualToString:@""])
        return YES;
    PFObject * patientObj = billingObj[PARSE_BILLING_PATIENT];
    NSString * medicalRecordNum = patientObj[PARSE_PATIENTS_RECORDNUMBER];
    if([Util stringIsMatched:medicalRecordNum searchKey:searchKey])
        return YES;
    NSString * finalNum = patientObj[PARSE_PATIENTS_FINALNUMBER];
    if([Util stringIsMatched:finalNum searchKey:searchKey])
        return YES;
    NSString * patientName = [NSString stringWithFormat:@"%@ %@", patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]];
    if([Util stringIsMatched:patientName searchKey:searchKey])
        return YES;
    NSString * dateStr = [Util convertDateToString:billingObj.updatedAt];
    if([Util stringIsMatched:dateStr searchKey:searchKey])
        return YES;
    NSString * instruction = patientObj[PARSE_PATIENTS_MEDICALINSURANCE];
    if([Util stringIsMatched:instruction searchKey:searchKey])
        return YES;
    NSArray * diagosis = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
    NSString * str = [diagosis componentsJoinedByString:@"\n"];
    if([Util stringIsMatched:str searchKey:searchKey])
        return YES;
    PFUser * owner = billingObj[PARSE_BILLING_OWNER];
    NSString * ownerName = [NSString stringWithFormat:@"%@ %@", owner[PARSE_USER_FIRSTNAME], owner[PARSE_USER_LASTSTNAME]];
    if([Util stringIsMatched:ownerName searchKey:searchKey])
        return YES;
    NSString  * billingCode = billingObj[PARSE_BILLING_CODE];
    if([Util stringIsMatched:billingCode searchKey:searchKey])
        return YES;
    return NO;
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
- (IBAction)onSelectCurrent:(id)sender {
    self.btn_current.selected = YES;
    self.btn_dischage.selected = NO;
    selectedType = 0;
    [self fetchData];
}
- (IBAction)onSelectDischage:(id)sender {
    self.btn_current.selected = NO;
    self.btn_dischage.selected = YES;
    selectedType = 1;
    [self fetchData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return searchedBillings.count + 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, 50);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BillingCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"BillingCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        if(indexPath.section == 0){
            NSMutableArray * titleArray = [[NSMutableArray alloc] initWithArray:@[@"Medical Record Number", @"Financial Identification Number", @"Patient Name", @"Date of Admission",  @"Medical Insurance", @"Diagnosis", @"Doctor", @"Billing Code"]];
            cell.lbl_title.text = [titleArray objectAtIndex:indexPath.row];
            [cell.lbl_title setFont:[UIFont boldSystemFontOfSize:14]];
        }else{
            [cell.lbl_title setFont:[UIFont systemFontOfSize:13]];
            int index = (int)indexPath.section -1;
            PFObject * billingObj = [searchedBillings objectAtIndex:index];
            PFObject * patientObj = billingObj[PARSE_BILLING_PATIENT];
            if(indexPath.row == 0){//@"Medical Record Number"
                NSString * medicalRecordNum = patientObj[PARSE_PATIENTS_RECORDNUMBER];
                cell.lbl_title.text = medicalRecordNum;
            }else if(indexPath.row == 1){//@"Financial Identification Number"
                NSString * finalNum = patientObj[PARSE_PATIENTS_FINALNUMBER];
                cell.lbl_title.text = finalNum;
            }else if(indexPath.row == 2){//@"Patient Name"
                NSString * patientName = [NSString stringWithFormat:@"%@ %@", patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]];
                cell.lbl_title.text = patientName;
            }else if(indexPath.row == 3){//@"Date of Admission"
                NSString * dateStr = [Util convertDateToString:billingObj.updatedAt];
                cell.lbl_title.text = dateStr;
            }else if(indexPath.row == 4){//@"Medical Insurance"
                NSString * instruction = patientObj[PARSE_PATIENTS_MEDICALINSURANCE];
                cell.lbl_title.text = instruction;
            }else if(indexPath.row == 5){//@"Diagnosis"
                NSArray * diagosis = patientObj[PARSE_PATIENTS_DIAGNOSISCODE];
                NSString * str = [diagosis componentsJoinedByString:@"\n"];
                cell.lbl_title.text = str;
            }else if(indexPath.row == 6){//@"Doctor"
                PFUser * owner = billingObj[PARSE_BILLING_OWNER];
                cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", owner[PARSE_USER_FIRSTNAME], owner[PARSE_USER_LASTSTNAME]];
            }else if(indexPath.row == 7){//@"Billing Code"
                NSString  * billingCode = billingObj[PARSE_BILLING_CODE];
                cell.lbl_title.text = billingCode;
            }
        }
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.section > 0){
        int index = (int)indexPath.section -1;
        PFObject * billingObj = [searchedBillings objectAtIndex:index];
        
        AdminBillingCollectionViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminBillingCollectionViewController"];
        controller.billingObj = billingObj;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
@end
