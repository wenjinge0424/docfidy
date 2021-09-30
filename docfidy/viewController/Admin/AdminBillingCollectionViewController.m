//
//  AdminBillingCollectionViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminBillingCollectionViewController.h"
#import "BillingCollectionViewCell.h"

@interface AdminBillingCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_note;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnDischarge;
@end

@implementation AdminBillingCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchData];
}
- (void) fetchData
{
    if([self.billingObj[PARSE_BILLING_PAYMENTCOMPLETE] boolValue]){
        [self.btnDischarge setHidden:YES];
    }else{
        [self.btnDischarge setHidden:NO];
    }
    PFObject * patientObj = self.billingObj[PARSE_BILLING_PATIENT];
    self.lbl_title.text = [NSString stringWithFormat:@"%@ %@", patientObj[PARSE_PATIENTS_FIRSTNAME], patientObj[PARSE_PATIENTS_LASTNAME]];
    self.lbl_note.text = patientObj[PARSE_PATIENTS_RECORDNUMBER];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    });
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
- (IBAction)onDischarge:(id)sender {
    self.billingObj[PARSE_BILLING_PAYMENTCOMPLETE] = [NSNumber numberWithBool:YES];
    [self showLoadingBar];
    [self.billingObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self hideLoadingBar];
        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return CGSizeMake(collectionView.frame.size.width / 3, 40);
    }
    return CGSizeMake(collectionView.frame.size.width / 3, 25);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BillingCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"BillingCollectionViewCell" forIndexPath:indexPath];
    if(cell){
        if(indexPath.row == 0){
            NSMutableArray * titleArray = [[NSMutableArray alloc] initWithArray:@[@"Billing Code", @"Billing Amount", @"Pending Payment"]];
            cell.lbl_title.text = [titleArray objectAtIndex:indexPath.section];
        }else{
            if(indexPath.section == 0){//@"Billing Code"
                NSString * billingCode = self.billingObj[PARSE_BILLING_CODE];
                cell.lbl_title.text = billingCode;
            }else if(indexPath.section == 1){//@"Billing Amount"
                NSString * billingAmount = [NSString stringWithFormat:@"$%d" , [self.billingObj[PARSE_BILLING_AMOUNT] intValue]];
                cell.lbl_title.text = billingAmount;
            }else if(indexPath.section == 2){//@"Billing Amount"
                NSString * pendingAmount = [NSString stringWithFormat:@"$%d" , [self.billingObj[PARSE_BILLING_AMOUNT] intValue]];
                cell.lbl_title.text = pendingAmount;
            }
        }
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}
@end
