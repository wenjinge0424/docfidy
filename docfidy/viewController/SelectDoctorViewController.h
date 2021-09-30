//
//  SelectDoctorViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/29/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectDoctorViewControllerDelegate
- (void) doctorSelected:(PFUser*)user withTag:(int)index;
@end

@interface SelectDoctorViewController : BaseViewController
@property (nonatomic, retain) id<SelectDoctorViewControllerDelegate>delegate;
@property (atomic) BOOL needAnyDoctor;
@property (atomic) BOOL needAnyNurse;
@property (nonatomic, retain) NSMutableArray * doctorArray;
@property (nonatomic, retain) NSMutableArray * ExceptionArray;
@property (nonatomic, retain) NSMutableArray * selectedArray;
@property (atomic) int ctrlIndex;
@property (nonatomic, retain) BIZPopupViewController * parent;
@end

NS_ASSUME_NONNULL_END
