//
//  ScheuleListTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheuleListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_gray;
@property (weak, nonatomic) IBOutlet UIView *view_darkgray;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_detail;

@end

NS_ASSUME_NONNULL_END
