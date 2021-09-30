//
//  AdminDailyScheduleViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdminDailyScheduleViewController : BaseViewController
@property (atomic) BOOL runTypeDoctor;
@property (nonatomic, retain) NSDate * selectedDate;
@end

NS_ASSUME_NONNULL_END
