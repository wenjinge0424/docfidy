//
//  EditBillingViewController.h
//  docfidy
//
//  Created by Techsviewer on 2/17/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditBillingViewController : BaseViewController
@property (nonatomic, retain) PFObject * patientObj;
@property (nonatomic, retain) PFObject * billObject;
@end

NS_ASSUME_NONNULL_END
