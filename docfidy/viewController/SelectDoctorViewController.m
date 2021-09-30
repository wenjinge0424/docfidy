//
//  SelectDoctorViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SelectDoctorViewController.h"
#import "TitleTableViewCell.h"

@interface SelectDoctorViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate>
{
    NSMutableArray * showData;
    NSMutableArray * searchedArray;
}
@property (weak, nonatomic) IBOutlet UISearchBar *m_searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;

@end

@implementation SelectDoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_searchBar.delegate = self;
    
    NSMutableArray * allDoctors = [NSMutableArray new];
    NSMutableArray * allNurses = [NSMutableArray new];
    for(PFUser * user in self.doctorArray){
        int userType = [user[PARSE_USER_TYPE] intValue];
        if(userType == 200){
            [allDoctors addObject:user];
        }else if(userType == 100){
            [allNurses addObject:user];
        }
    }
    if(self.needAnyDoctor){
        self.doctorArray = [[NSMutableArray alloc] initWithArray:allDoctors];
    }else if(self.needAnyNurse){
        self.doctorArray = [[NSMutableArray alloc] initWithArray:allNurses];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData:@""];
}
- (BOOL) isContainsInException:(PFUser*)doctor
{
    for(NSObject * subString in self.ExceptionArray){
        if([subString isKindOfClass:[PFUser class]]){
            if([((PFUser*)subString).objectId isEqualToString:doctor.objectId]){
                return YES;
            }
        }
    }
    return NO;
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * searchStr = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self reloadTableForKey:searchStr];
    return YES;
}
- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    [self reloadTableForKey:@""];
    return YES;
}
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""]){
        [self reloadTableForKey:@""];
    }
}
- (void) reloadTableForKey:(NSString*)searchString
{
    searchedArray = [NSMutableArray new];
    for (PFUser * subUser in showData) {
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
- (void) reloadData:(NSString*)searchString
{
    showData = [NSMutableArray new];
    for(PFUser * subStr in self.doctorArray){
        if(![searchString isEqualToString:@""]){
            NSString * doctorName = [NSString stringWithFormat:@"%@ %@", subStr[PARSE_USER_FIRSTNAME], subStr[PARSE_USER_LASTSTNAME]];
            if([Util stringIsMatched:doctorName searchKey:searchString]){
                if(![self isContainsInException:subStr])
                    [showData addObject:subStr];
            }
        }else{
            if(![self isContainsInException:subStr])
                [showData addObject:subStr];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableForKey:self.m_searchBar.text];
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
- (IBAction)onCancel:(id)sender {
    [self.parent dismissPopupViewControllerAnimated:YES];
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
        int userType = [currentUser[PARSE_USER_TYPE] intValue];
        if(userType == 200){
            NSString * fullName = [NSString stringWithFormat:@"Dr. %@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
            cell.lbl_title.text = fullName;
        }else{
            NSString * fullName = [NSString stringWithFormat:@"      %@ %@", currentUser[PARSE_USER_FIRSTNAME], currentUser[PARSE_USER_LASTSTNAME]];
            cell.lbl_title.text = fullName;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFUser * currentUser = [searchedArray objectAtIndex:indexPath.row];
    [self.delegate doctorSelected:currentUser withTag:self.ctrlIndex];
    [self.parent dismissPopupViewControllerAnimated:YES];
}

@end
