//
//  DoctorHomeTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoctorBillingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_color_container;
@property (weak, nonatomic) IBOutlet UILabel *lbl_number;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow_right;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow_bottom;
@property (weak, nonatomic) IBOutlet UIButton *btn_collapse;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_value;
@property (weak, nonatomic) IBOutlet UITableView *view_table;
@property (weak, nonatomic) IBOutlet UIButton *btnCPTCode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_numberWidth;

- (void) resizeNumberLabel;
@end


@interface DoctorHomeHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_color_container;
@property (weak, nonatomic) IBOutlet UILabel *lbl_number;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow_right;
@property (weak, nonatomic) IBOutlet UIButton *btn_doctor;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_arrow_bottom;
@property (weak, nonatomic) IBOutlet UIButton *btn_collapse;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constant_numberWidth;
- (void) resizeNumberLabel;
@end

@interface DoctorHomeDoctorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_message;

@end

@interface DoctorHomeActionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btn_note;
@property (weak, nonatomic) IBOutlet UIButton *btn_doctor;

@end

NS_ASSUME_NONNULL_END
