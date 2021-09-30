//
//  ChattingViewController.h
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChattingViewController : BaseViewController
@property (nonatomic, retain) PFObject * mesageChannelInfo;
@property (nonatomic, retain) PFUser * mesageReceiverInfo;
@property (nonatomic, retain) PFObject * linkedPatientInfo;
@end

NS_ASSUME_NONNULL_END
