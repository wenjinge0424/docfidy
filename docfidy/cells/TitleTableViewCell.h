//
//  TitleTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/27/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TitleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIImageView *img_checker;

@end

NS_ASSUME_NONNULL_END
