//
//  DoctorNoteTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoctorNoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_patient;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_detail;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;

@end

NS_ASSUME_NONNULL_END
