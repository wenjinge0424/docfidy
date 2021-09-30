//
//  MessageRecipeViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "MessageRecipeViewController.h"
#import "TitleTableViewCell.h"

@interface MessageRecipeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * allDoctors;
    NSMutableArray * recipes;
    NSMutableArray * selectedDoctors;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_doctors;
@end

@implementation MessageRecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchData];
}
- (void) fetchData{
    PFUser * me = [PFUser currentUser];
    allDoctors = [NSMutableArray new];
    recipes = [NSMutableArray new];
    selectedDoctors = [NSMutableArray new];
    if(self.alreadySelectedDoctors && self.alreadySelectedDoctors.count > 0){
        selectedDoctors = [[NSMutableArray alloc] initWithArray:self.alreadySelectedDoctors];
    }
    [self showLoadingBar];
    PFQuery * doctorquery = [PFUser query];
    [doctorquery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:200]];
    PFQuery * nursequery = [PFUser query];
    [nursequery whereKey:PARSE_USER_TYPE equalTo:[NSNumber numberWithInt:100]];
    
    PFQuery * userQuery = [PFQuery orQueryWithSubqueries:@[doctorquery, nursequery]];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        if (error){
            [self hideLoadingBar];
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFUser *subDoctor = [array objectAtIndex:i];
                [allDoctors addObject:subDoctor];
                if(![subDoctor.objectId isEqualToString:me.objectId]){
                    [recipes addObject:subDoctor];
                }
            }
            [[AppStateManager sharedInstance] setDoctorArray:allDoctors];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoadingBar];
                self.tbl_doctors.delegate = self;
                self.tbl_doctors.dataSource = self;
                [self.tbl_doctors reloadData];
            });
        }
        
    }];
}
- (BOOL) doctorContainsIn:(NSMutableArray*)doctors forDoctor:(PFUser*)doctor
{
    for(PFUser * subDoctor in doctors){
        if([subDoctor.objectId isEqualToString:doctor.objectId]){
            return YES;
        }
    }
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
- (IBAction)onDone:(id)sender {
    if(selectedDoctors.count == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please select doctors."];
    }else{
//        [self.delegate didmissWithArray:selectedDoctors];
        self.messageRoomObj[PARSE_ROOM_PARTICIPANTS] = selectedDoctors;
        [self showLoadingBar];
        [self.messageRoomObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self hideLoadingBar];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recipes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TitleTableViewCell";
    TitleTableViewCell *cell = (TitleTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell){
        PFUser * doctorInfo = [recipes objectAtIndex:indexPath.row];
        cell.lbl_title.text = [NSString stringWithFormat:@"%@ %@", doctorInfo[PARSE_USER_FIRSTNAME], doctorInfo[PARSE_USER_LASTSTNAME]];
        cell.img_checker.hidden = YES;
        if([self doctorContainsIn:selectedDoctors forDoctor:doctorInfo]){
            cell.img_checker.hidden = NO;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PFUser * doctorInfo = [recipes objectAtIndex:indexPath.row];
    if([self doctorContainsIn:selectedDoctors forDoctor:doctorInfo]){
        for(PFUser * user in selectedDoctors){
            if([user.objectId isEqualToString:doctorInfo.objectId]){
                [selectedDoctors removeObject:user];
            }
        }
    }else{
        [selectedDoctors addObject:doctorInfo];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
@end
