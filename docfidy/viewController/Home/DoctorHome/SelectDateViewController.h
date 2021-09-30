//
//  SelectDateViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectDateViewControllerDelegate
- (void) SelectDateViewControllerDelegate_didSelectDate:(NSDate*)date;
@end

@interface SelectDateViewController : BaseViewController
@property (nonatomic, retain) id<SelectDateViewControllerDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
