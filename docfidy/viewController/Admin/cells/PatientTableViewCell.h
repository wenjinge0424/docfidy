//
//  PatientTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Title_PatientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_patientName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_recordNum;
@property (weak, nonatomic) IBOutlet UILabel *lbl_birthday;
@property (weak, nonatomic) IBOutlet UIButton *btnDischarge;

@end

@interface Action_PatientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_transfer;

@end

@interface List_PatientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete;
@property (weak, nonatomic) IBOutlet UIButton *btn_message;

@end

@interface Visit_PatientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_detail;

@end
NS_ASSUME_NONNULL_END
