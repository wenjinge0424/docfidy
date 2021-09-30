//
//  DoctorHomeTableViewCell.m
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctorHomeTableViewCell.h"

@implementation DoctorBillingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (CGSize)calculateWidthForString:(NSString *)str
{
    CGSize size = CGSizeZero;
    
    UIFont *labelFont = [UIFont systemFontOfSize:13.0f];
    NSDictionary *systemFontAttrDict = [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:str attributes:systemFontAttrDict];
    CGRect rect = [message boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];//you need to specify the some width, height will be calculated
    size = CGSizeMake(rect.size.width, rect.size.height + 5); //padding
    
    return size;
    
}
- (void) resizeNumberLabel
{
    UITextView *textView = [[UITextView alloc] init];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(50, 40);
    textView.frame = newFrame;
    NSString *text = self.lbl_number.text;
    textView.text = text;
    
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    [textView sizeToFit];
    textView.scrollEnabled =NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize new = [self calculateWidthForString:text];
    CGRect newFrame1 = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, new.height);
    textView.frame = newFrame1;
    float width = new.width + 5;
    if(width > 100)
        width = 100;
    self.constant_numberWidth.constant = width;
    [self setNeedsDisplay];
}
@end

@implementation DoctorHomeHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (CGSize)calculateWidthForString:(NSString *)str
{
    CGSize size = CGSizeZero;
    
    UIFont *labelFont = [UIFont systemFontOfSize:13.0f];
    NSDictionary *systemFontAttrDict = [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:str attributes:systemFontAttrDict];
    CGRect rect = [message boundingRectWithSize:(CGSize){MAXFLOAT, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];//you need to specify the some width, height will be calculated
    size = CGSizeMake(rect.size.width, rect.size.height + 5); //padding
    
    return size;
    
}
- (void) resizeNumberLabel
{
    UITextView *textView = [[UITextView alloc] init];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(50, 40);
    textView.frame = newFrame;
    NSString *text = self.lbl_number.text;
    textView.text = text;
    
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    [textView sizeToFit];
    textView.scrollEnabled =NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize new = [self calculateWidthForString:text];
    CGRect newFrame1 = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, new.height);
    textView.frame = newFrame1;
    float width = new.width + 5;
    if(width > 100)
        width = 100;
    self.constant_numberWidth.constant = width;
    [self setNeedsDisplay];
}
@end

@implementation DoctorHomeDoctorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

@implementation DoctorHomeActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
