//
//  CustomTableViewCell.h
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// height 50
@interface TextEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *edt_text;
@property (weak, nonatomic) IBOutlet UIButton *btn_action;

@end

@interface RightCornerButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btn_action;

@end


NS_ASSUME_NONNULL_END
