//
//  SignUpPatternViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define RUN_TYPE_SIGNUP    0
#define RUN_TYPE_SETTING    1

@interface SignUpPatternViewController : BaseViewController
@property (atomic) int runType;
@property (nonatomic, retain) PFUser * user;
@end

NS_ASSUME_NONNULL_END
