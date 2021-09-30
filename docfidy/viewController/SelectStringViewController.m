//
//  SelectStringViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SelectStringViewController.h"
#import "TitleTableViewCell.h"

@interface SelectStringViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate>
{
    NSMutableArray * showData;
}
@property (weak, nonatomic) IBOutlet UISearchBar *m_searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@end

@implementation SelectStringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.m_searchBar.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData:@""];
}
- (BOOL) isContainsInException:(NSString*)string
{
    for(NSString * subString in self.ExceptionArray){
        if([subString isEqualToString:string]){
            return YES;
        }
    }
    return NO;
}
- (void) reloadData:(NSString*)searchString
{
    showData = [NSMutableArray new];
    searchString = [searchString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    for(NSString * subStr in self.stringArray){
        if(![searchString isEqualToString:@""]){
            if([Util stringIsMatched:subStr searchKey:searchString]){
                if(![self isContainsInException:subStr])
                    [showData addObject:subStr];
            }
        }else{
            if(![self isContainsInException:subStr])
                [showData addObject:subStr];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource = self;
        [self.tbl_data reloadData];
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
    return showData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        cell.lbl_title.text = [showData objectAtIndex:indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.delegate stringSelected:[showData objectAtIndex:indexPath.row] withTag:self.ctrolIndex];
    [self.parent dismissPopupViewControllerAnimated:YES];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * searchStr = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self reloadData:searchStr];
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    [self reloadData:@""];
    return YES;
}
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""]){
        [self reloadData:@""];
    }
}
@end
