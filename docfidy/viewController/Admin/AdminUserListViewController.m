//
//  AdminUserListViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/27/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AdminUserListViewController.h"
#import "TitleTableViewCell.h"
#import "AdminUserProfileViewController.h"
#import "AdminInvitationViewController.h"

@interface AdminUserListViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray * dataArray;
    NSMutableArray * searchedArray;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UITextField *edt_search;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;

@end

@implementation AdminUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_search.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_search.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    if(self.viewType == VIEW_TYPE_DOCTOR){
        self.lbl_title.text = @"Doctors";
    }else if(self.viewType == VIEW_TYPE_NURSE){
        self.lbl_title.text = @"Nurses";
    }else if(self.viewType == VIEW_TYPE_PERSON){
        self.lbl_title.text = @"Other Health Professionals";
    }
    self.edt_search.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchData];
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self reloadTableForKey:searchStr];
    return YES;
}
- (void) reloadTableForKey:(NSString*)searchString
{
    searchedArray = [NSMutableArray new];
    for (PFUser * subUser in dataArray) {
        if(![searchString isEqualToString:@""]){
            NSString * doctorName = [NSString stringWithFormat:@"%@ %@", subUser[PARSE_USER_FIRSTNAME], subUser[PARSE_USER_LASTSTNAME]];
            if([Util stringIsMatched:doctorName searchKey:searchString]){
                [searchedArray addObject:subUser];
            }
        }else{
            [searchedArray addObject:subUser];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource  = self;
        [self.tbl_data reloadData];
    });
}
- (void) fetchData
{
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    dataArray = [[NSMutableArray alloc] init];
    [self showLoadingBar];
    PFQuery *query = [PFUser query];
    if(self.viewType == VIEW_TYPE_DOCTOR){
        [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    }else if(self.viewType == VIEW_TYPE_NURSE){
        [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
    }else if(self.viewType == VIEW_TYPE_PERSON){
        [query whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:300]];
    }
    [query whereKey:PARSE_USER_IS_BANNED notEqualTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *owner = [array objectAtIndex:i];
                [dataArray addObject:owner];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableForKey:self.edt_search.text];
            });
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
- (IBAction)onAdd:(id)sender {
    AdminInvitationViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminInvitationViewController"];
    controller.viewType = self.viewType;
    [self.navigationController pushViewController:controller animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFUser * currentUser = [searchedArray objectAtIndex:indexPath.row];
        if(self.viewType == VIEW_TYPE_DOCTOR){
            NSString * fullName = [NSString stringWithFormat:@"Dr. %@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
            cell.lbl_title.text = fullName;
        }else{
            NSString * fullName = [NSString stringWithFormat:@"%@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
            cell.lbl_title.text = fullName;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFUser * currentUser = [searchedArray objectAtIndex:indexPath.row];
    AdminUserProfileViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AdminUserProfileViewController"];
    controller.user = currentUser;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
