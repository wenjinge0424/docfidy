//
//  MessageTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "CircleImageView.h"

NS_ASSUME_NONNULL_BEGIN
///65
@interface GroupMessageTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_groupName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_lastMessage;

@end
//85
@interface UserMessageTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_doctorName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_patientInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_lastMessage;
@property (weak, nonatomic) IBOutlet CircleImageView *img_userThumb;
- (void) setPatientInfo:(NSString*)info;
@end

NS_ASSUME_NONNULL_END
