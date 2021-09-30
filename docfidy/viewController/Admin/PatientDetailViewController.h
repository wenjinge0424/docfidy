//
//  PatientDetailViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface PatientDetailViewController : BaseViewController
@property (nonatomic, retain) PFObject * patientObj;
@property (atomic) int runType;
@end

NS_ASSUME_NONNULL_END
