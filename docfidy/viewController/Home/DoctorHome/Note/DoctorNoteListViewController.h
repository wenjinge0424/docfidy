//
//  DoctorNoteListViewController.h
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoctorNoteListViewController : BaseViewController
@property (nonatomic, retain) PFObject * selectedPatientObj;
@end

NS_ASSUME_NONNULL_END
