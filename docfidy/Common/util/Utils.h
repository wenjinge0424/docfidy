//
//  Utils.h
//  DailyMessageTruthRevealed
//
//  Created by Techsviewer on 5/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CSVUtil.h"

@interface Util : NSObject
+ (NSString *) trim:(NSString *) string;
+ (NSString *) checkSpace:(NSString *) string;
+ (NSString *) randomStringWithLength: (int) len;
+ (AppDelegate*) appDelegate;
+ (BOOL) isConnectableInternet;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message finish:(void (^)(void))finish;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message info:(BOOL)info;
+ (BOOL) isPhotoAvaileble;

+ (void) setAdminNameAndPassword:(NSString*)adminName :(NSString*)password;
+ (NSString *) getAdminName;
+ (NSString *) getAdminPassword;

+ (NSString*) convertDateToString:(NSDate*)date;
+ (NSString*) convertDateTimeToString:(NSDate*)date;

+ (NSDate*) yesterday:(NSDate*)date;
+ (NSDate*) tomorrow:(NSDate*)date;
+ (int) getHour:(NSDate*)date;
+ (NSMutableArray*) getDateStartAndEnd:(NSDate*)date;
+ (NSDate*) getFullDateFrom:(NSDate*)date withTime:(NSDate*)time;

+ (BOOL) stringContainsInArray:(NSString*)string :(NSArray*)stringArray;
+ (BOOL) stringContainNumber:(NSString *) string;
+ (BOOL) stringContainLetter:(NSString *) string;
+ (BOOL) isContainsUpperCase:(NSString *) password;
+ (BOOL) isContainsLowerCase:(NSString *) password;
+ (BOOL) isContainsNumber:(NSString *) password;
+ (BOOL) stringIsNumber:(NSString*) str;
+ (BOOL) stringIsMatched:(NSString*)original searchKey:(NSString*)key;

+ (NSMutableArray *) removeItem:(PFUser*)item in:(NSMutableArray*)array;


+ (void) setLoginUserName:(NSString*) userName password:(NSString*) password;
+ (NSString*) getLoginUserName;
+ (NSString*) getLoginUserPassword;

+ (void) setUnlockPattern:(NSString*)pattern;
+ (NSString *) getUnlockPattern;

+ (UIImage *)getUploadingUserImageFromImage:(UIImage *)image;

+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile withDefault:(UIImage*)image;
+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile;
+ (NSString *) downloadedURL:(NSString *)url name:(NSString *) name;
+ (void) downloadFile:(NSString *)url name:(NSString *) name completionBlock:(void (^)(NSURL *downloadurl, NSData *data, NSError *err))completionBlock;
+ (NSString *) getDocumentDirectory;
+ (NSString *)urlparseCDN:(NSString *)url;

+ (UIImage *)getUploadingImageFromImage:(UIImage *)image;

+ (void) sendPushNotification:(NSString *)email message:(NSString *)message type:(int)type;


+ (BOOL) isPhotoAvaileble;
+ (BOOL) isCameraAvailable;

@end
