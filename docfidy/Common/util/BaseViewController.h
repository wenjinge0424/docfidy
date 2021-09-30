//
//  BaseViewController.h
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/19/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "Config.h"
#import "SCLAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+Email.h"
#import "MBProgressHUD.h"
#import "IQDropDownTextField.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "CircleImageView.h"
#import "BIZPopupViewController.h"
#import "IQTextView.h"
#import "NSString+Case.h"
#import "IQTextView.h"
#import "UITextView+Placeholder.h"
#import "NSDate+NVTimeAgo.h"
#import "NSDate+TimeDifference.h"
#import "AIDatePickerController.h"
#import "PickerView.h"


@interface BaseViewController : UIViewController
- (IBAction)onBack:(id)sender;
- (void)onMessages:(PFUser*)owner;
- (void) onShareAction:(PFObject*)post;
- (void) onPlayVideo:(PFFile*)video;
- (void) onShowPFImage:(PFFile*)image;
- (PFUser*) getUserFromId:(NSString*)userId inArray:(NSMutableArray*)userArray;

- (void) onSendMessageTo:(PFUser *) user inPatient:(PFObject*)patient;

- (void) showLoadingBar;
- (void) hideLoadingBar;
@end
