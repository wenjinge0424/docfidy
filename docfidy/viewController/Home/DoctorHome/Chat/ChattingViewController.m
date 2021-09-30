//
//  ChattingViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "ChattingViewController.h"
#import "ChatDetailsViewController.h"

@interface ChattingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_patientName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_patientNum;
@property (weak, nonatomic) IBOutlet UIView *view_patientContain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_patient_height;

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BOOL isGroup = [self.mesageChannelInfo[PARSE_ROOM_ISGROUP] boolValue];
    if(isGroup){
        self.constant_patient_height.constant = 0;
        [self.view setNeedsDisplay];
        [self.view_patientContain setHidden:YES];
        self.lbl_title.text = self.mesageChannelInfo[PARSE_ROOM_GROUPNAME];
    }else{
        self.constant_patient_height.constant = 60;
        [self.view setNeedsDisplay];
        [self.view_patientContain setHidden:NO];
        self.lbl_title.text = [NSString stringWithFormat:@"%@ %@", self.mesageReceiverInfo[PARSE_USER_FIRSTNAME], self.mesageReceiverInfo[PARSE_USER_LASTSTNAME]];
        self.lbl_patientName.text = [NSString stringWithFormat:@"%@ %@", self.linkedPatientInfo[PARSE_PATIENTS_FIRSTNAME], self.linkedPatientInfo[PARSE_PATIENTS_LASTNAME]];
        self.lbl_patientNum.text = self.linkedPatientInfo[PARSE_PATIENTS_RECORDNUMBER];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BOOL isGroup = [self.mesageChannelInfo[PARSE_ROOM_ISGROUP] boolValue];
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatDetailsViewController *vc = (ChatDetailsViewController *) segue.destinationViewController;
        if(!isGroup){
            vc.toUsers = [[NSMutableArray alloc] initWithObjects:self.mesageReceiverInfo, nil];
        }else{
            vc.toUsers = self.mesageChannelInfo[PARSE_ROOM_PARTICIPANTS];
        }
        vc.room = self.mesageChannelInfo;
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
