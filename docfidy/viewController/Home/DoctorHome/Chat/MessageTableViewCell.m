//
//  MessageTableViewCell.m
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation GroupMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation UserMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.lbl_patientInfo.layer.cornerRadius = 5.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void) setPatientInfo:(NSString*)info
{
    self.lbl_patientInfo.text = [NSString stringWithFormat:@"  %@  ", info];
}
@end
