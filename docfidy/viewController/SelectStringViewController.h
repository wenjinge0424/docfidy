//
//  SelectStringViewController.h
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SelectStringViewControllerDelegate
- (void) stringSelected:(NSString*)str withTag:(int)tag;
@end


@interface SelectStringViewController : BaseViewController
@property (nonatomic, retain) id<SelectStringViewControllerDelegate>delegate;
@property (atomic) int ctrolIndex;
@property (nonatomic, retain) NSMutableArray * stringArray;
@property (nonatomic, retain) NSMutableArray * ExceptionArray;
@property (nonatomic, retain) BIZPopupViewController * parent;
@end

NS_ASSUME_NONNULL_END
