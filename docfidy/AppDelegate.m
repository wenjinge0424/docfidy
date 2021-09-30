//
//  AppDelegate.m
//  docfidy
//
//  Created by Techsviewer on 1/25/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;
@import GooglePlaces;
#import "Utils.h"
#import "Config.h"
#import "SCLAlertView.h"
#import "Onboard1ViewController.h"
#import "LoginViewController.h"
#import "SignUpPatternViewController.h"
#import "CheckPatternViewController.h"
#import "ChatDetailsViewController.h"
#import "MessageViewController.h"
#import "ClientHomeViewController.h"
#import "NurseHomeViewController.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
@property(nonatomic, strong) CLLocationManager *manager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GMSPlacesClient provideAPIKey:@""];
    [GIDSignIn sharedInstance].clientID = @"";
    
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"";
        configuration.clientKey = @"";
        configuration.server = @"https://parse.jimb.tk:20013/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    /// gms
    _manager = [CLLocationManager new];
    _manager.delegate = self;
    _manager.distanceFilter = kCLDistanceFilterNone;
    _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _manager.pausesLocationUpdatesAutomatically = NO;
    _manager.headingFilter = 5;
    _manager.distanceFilter = 0;
    [_manager requestAlwaysAuthorization];
    [_manager startUpdatingLocation];
    [_manager startUpdatingHeading];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    BOOL readOnboard = [[NSUserDefaults standardUserDefaults] boolForKey:SYSTEM_KEY_READ_ONBOARD];
    UINavigationController * mainNav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AppMainNav"];
    self.m_mainNav = mainNav;
    if(!readOnboard){
        Onboard1ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard1ViewController"];
        [mainNav setViewControllers:@[controller] animated:NO];
    }else{
        if ([Util getLoginUserName].length > 0 && [Util getLoginUserPassword].length > 0 && [Util getUnlockPattern].length > 0){
            CheckPatternViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CheckPatternViewController"];
            [mainNav setViewControllers:@[controller] animated:NO];
        }else{
            LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [mainNav setViewControllers:@[controller] animated:NO];
        }
    }
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    
    if(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]){
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_BACKGROUND object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_ACTIVE object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void) showLoadingBar
{
    [MBProgressHUD showHUDAddedTo:self.m_mainNav.view animated:YES];
}
- (void) hideLoadingBar
{
    [MBProgressHUD hideHUDForView:self.m_mainNav.view animated:YES];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSInteger pushType = [[userInfo objectForKey:PUSH_NOTIFICATION_TYPE] integerValue];
    application.applicationIconBadgeNumber = 0;
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    } else { // active status
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    
    PFUser * me = [PFUser currentUser];
    if(me){
        [me fetchIfNeeded];
        if([me[PARSE_USER_DONOTDISCRIB] boolValue]){
            return;
        }
    }
    
    
    if (pushType == PUSH_TYPE_CHAT){
        if ([ChatDetailsViewController getInstance]){
            NSString * myObjectid = me.objectId;
            NSUserDefaults * userDefault =  [NSUserDefaults standardUserDefaults];
            int unreadCount = [[userDefault objectForKey:myObjectid] intValue];
            unreadCount = 0;
            [userDefault setValue:[NSNumber numberWithInt:unreadCount] forKey:myObjectid];
            [userDefault synchronize];
            
            NSString *roomId = [userInfo objectForKey:@"data"];
            if ([roomId isEqualToString:[AppStateManager sharedInstance].chatRoomId]){
                [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:nil];
            } else {
                [PFPush handlePush:userInfo];
            }
        } else if ([MessageViewController getInstance]){
            NSString * myObjectid = me.objectId;
            NSUserDefaults * userDefault =  [NSUserDefaults standardUserDefaults];
            int unreadCount = [[userDefault objectForKey:myObjectid] intValue];
            unreadCount = 0;
            [userDefault setValue:[NSNumber numberWithInt:unreadCount] forKey:myObjectid];
            [userDefault synchronize];
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationMessageRooms object:nil];
        } else {
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotification object:nil];
            if(me){
                NSString * myObjectid = me.objectId;
                NSUserDefaults * userDefault =  [NSUserDefaults standardUserDefaults];
                int unreadCount = [[userDefault objectForKey:myObjectid] intValue];
                unreadCount += 1;
                [userDefault setValue:[NSNumber numberWithInt:unreadCount] forKey:myObjectid];
                [userDefault synchronize];
                
                if([ClientHomeViewController createInstance]){
                    [[ClientHomeViewController createInstance] setBageCount];
                }
                if([NurseHomeViewController createInstance]){
                    [[NurseHomeViewController createInstance] setBageCount];
                }
            }
        }
    } else if (pushType == PUSH_TYPE_BAN){
        if(self.m_mainNav){
            LoginViewController * loginViewController = nil;
            for(UIViewController * controller in self.m_mainNav.viewControllers){
                if([controller isKindOfClass:[LoginViewController class]]){
                    loginViewController = (LoginViewController*)controller;
                }
            }
            [Util showAlertTitle:self.m_mainNav title:@"Logout" message:@"Your account banned by app admin." finish:^{
                [self showLoadingBar];
                [PFUser logOutInBackgroundWithBlock:^(NSError *error){
                    [self hideLoadingBar];
                    [Util setLoginUserName:@"" password:@""];
                    if(loginViewController){
                        [self.m_mainNav popToViewController:loginViewController animated:YES];
                    }else{
                        LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
                        [self.m_mainNav pushViewController:controller animated:YES];
                    }
                }];
            }];
        }
    } else if( pushType == PUSH_TYPE_DISTRIBE){
        NSString * message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        [Util showAlertTitle:self.m_mainNav title:@"" message:message];
    }
}

- (void) checkTDBRate
{
    [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:50];
}
- (void) showRateDlg
{
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1237147"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:10];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (void)startUpdatingLocations {
    
    NSLog(@"START UPDATING LOCATION");
    [self.manager startUpdatingLocation];
}

- (void)stopUpdatingLocations {
    
    [self.manager stopUpdatingLocation];
    
    [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
    self.manager.pausesLocationUpdatesAutomatically = NO;
    self.manager.activityType = CLActivityTypeAutomotiveNavigation;
    [self.manager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ([locations lastObject]) {
        CLLocation * newLocation = [locations lastObject];
        self.currentLocation = newLocation;
    }
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
            
            
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            // We got authorization so
            // 1. Start tracking user location
            [self startUpdatingLocations];
            
            break;
        }
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            // We got authorization so
            // 1. Start tracking user location
            [self startUpdatingLocations];
            
            break;
        }
            
            
        case kCLAuthorizationStatusDenied:
        {
            // User has denied or not determined authorization for location
            // 1. Warn him.
            // Current location is now null
        }
            
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{}


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
}
@end
