//
//  AddNewPatientViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddNewPatientViewController : BaseViewController
@property (atomic) int runType;
@property (nonatomic, retain) PFObject * currentPatient;
@end

NS_ASSUME_NONNULL_END
