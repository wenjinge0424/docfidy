//
//  AppDelegate.h
//  docfidy
//
//  Created by Techsviewer on 1/25/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PFFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (atomic) BOOL needTDBRate;
@property (nonatomic, retain) UINavigationController * m_mainNav;
@property (nonatomic, retain) CLLocation * currentLocation;

- (void) checkTDBRate;
@end

