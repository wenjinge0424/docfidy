//
//  ScheduleGraphTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleGraphLineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_line;
@property (weak, nonatomic) IBOutlet UILabel *lbl_rect;

@end

@interface ScheduleGraphDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;

@end

NS_ASSUME_NONNULL_END
