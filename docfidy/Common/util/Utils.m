//
//  Utils.m
//  DailyMessageTruthRevealed
//
//  Created by Techsviewer on 5/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "Utils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "SCLAlertView.h"
#import "Config.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+AFNetworking_UIActivityIndicatorView.h"

#define PARSE_SERVER_BASE                  @"parse.brainyapps.com"
#define PARSE_CDN_BASE                     @"d2zvprcpdficqw.cloudfront.net"
#define PARSE_CDN_DECNUM                   10000

@implementation Util

+ (void) sendPushNotification:(NSString *)email message:(NSString *)message type:(int)type{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          email, @"email",
                          message, @"alert",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          @"", @"data",
                          [NSNumber numberWithInt:type], @"type",
                          nil];
    
    [PFCloud callFunctionInBackground:@"SendPush" withParameters:data block:^(id object, NSError *err) {
        if (err) {
            NSLog(@"Fail APNS: %@", message);
        } else {
            NSLog(@"Success APNS: %@", message);
        }
    }];
}

+ (NSString *) trim:(NSString *) string {
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    return newString;
}
+ (NSString *) checkSpace:(NSString *) string
{
    NSString *newString = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString * newnewString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newnewString;
}
+ (NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()_+=|\{}[]:',./?><;";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", (unichar) [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}
+ (AppDelegate*) appDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (BOOL) isConnectableInternet {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    } else {
        NSLog(@"There IS internet connection");
        return YES;
    }
}
+ (NSMutableArray *) removeItem:(PFUser*)item in:(NSMutableArray*)array
{
    NSMutableArray * newArray = [NSMutableArray new];
    for(PFUser * obj in array){
        if(![obj.objectId isEqualToString:item.objectId]){
            [newArray addObject:obj];
        }
    }
    return newArray;
}

+ (BOOL) stringContainsInArray:(NSString*)string :(NSArray*)stringArray
{
    for (NSString * substring in stringArray) {
        if([string isEqualToString:substring])
            return YES;
    }
    return NO;
}
+ (BOOL) stringContainNumber:(NSString *) string
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}
+ (BOOL) isContainsNumber:(NSString *)password {
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    if ([password rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL) isContainsLowerCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[a-z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}

+ (BOOL) isContainsUpperCase:(NSString *)password {
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:@"^.*(?=.*[A-Z])" options:0 error:nil];
    return [regex numberOfMatchesInString:password options:0 range:NSMakeRange(0, [password length])] > 0;
}
+ (BOOL) stringContainLetter:(NSString *) string
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ"] invertedSet];
    
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL) stringIsNumber:(NSString*) str
{
    NSScanner * sc = [NSScanner scannerWithString:str];
    if([sc scanFloat:NULL]){
        return [sc isAtEnd];
    }
    return NO;
}
+ (BOOL) stringIsMatched:(NSString*)original searchKey:(NSString*)key
{
    NSString * target = [original lowercaseString];
    if(!target || target.length == 0)
        return NO;
    NSString * lowKey = [key lowercaseString];
    NSRange rage = [target rangeOfString:lowKey];
    BOOL found = (rage.location != NSNotFound);
    return found;
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = [UIColor colorWithRed:2/255.f green:114/255.f blue:202/255.f alpha:1.f];
    
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message finish:(void (^)(void))finish
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
        if (finish) {
            finish ();
        }
    }];
    [alert setForceHideBlock:^{
        if (finish) {
            finish ();
        }
    }];
    alert.customViewColor = MAIN_COLOR;
    
    [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message info:(BOOL)info
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    alert.shouldDismissOnTapOutside = YES;
    alert.showAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
    }];
    alert.customViewColor = MAIN_COLOR;
    
    if (info)
        [alert showInfo:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
    else
        [alert showQuestion:vc title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}
+ (void) setLoginUserName:(NSString*) userName password:(NSString*) password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:@"userName"];
    [defaults setObject:password forKey:@"password"];
    [defaults synchronize];
    
    // Installation
    if (userName.length > 0 && password.length > 0) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setObject:[PFUser currentUser] forKey:@"owner"];
        [currentInstallation saveInBackground];
    } else {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectForKey:@"owner"];
        [currentInstallation saveInBackground];
    }
}
+ (void) setAdminNameAndPassword:(NSString*)adminName :(NSString*)password
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:adminName forKey:@"adminName"];
    [defaults setObject:password forKey:@"adminpassword"];
    [defaults synchronize];
}
+ (NSString *) getAdminName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"adminName"];
    return userName;
}
+ (NSString *) getAdminPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"adminpassword"];
    return userName;
}

+ (NSString*) getLoginUserName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    return userName;
}

+ (NSString*) getLoginUserPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"password"];
    return password;
}

+ (void) setUnlockPattern:(NSString*)pattern
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pattern forKey:@"unLockPattern"];
    [defaults synchronize];
}
+ (NSString *) getUnlockPattern
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *password = [defaults objectForKey:@"unLockPattern"];
    return password;
}

+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile withDefault:(UIImage*)image
{
    NSString *imageURL;
    [imgView setImage:image];
    imageURL = [Util downloadedURL:imgFile.url name:nil];
    if (!imageURL) {
        imageURL = [Util urlparseCDN:imgFile.url];
        [Util downloadFile:imageURL name:nil completionBlock:nil];
    }
    
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}
+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile {
    NSString *imageURL;
    [imgView setImage:[UIImage new]];
    imageURL = [Util downloadedURL:imgFile.url name:nil];
    if (!imageURL) {
        imageURL = [Util urlparseCDN:imgFile.url];
        [Util downloadFile:imageURL name:nil completionBlock:nil];
    }
    
    [imgView setImageWithURL:[NSURL URLWithString:imageURL] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
}
+ (NSDate*) yesterday:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:date options:0];
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    return yesterday;
}
+ (NSDate*) tomorrow:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:date options:0];
    [components setHour:24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *tomorrow = [cal dateByAddingComponents:components toDate: today options:0];
    return tomorrow;
}
+ (int) getHour:(NSDate*)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    return components.hour;
}
+ (NSDate*) getFullDateFrom:(NSDate*)date withTime:(NSDate*)time
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components_day = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    NSDateComponents *components_time = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:time];
    [components_day setYear:components_day.year];
    [components_day setMonth:components_day.month];
    [components_day setDay:components_day.day];
    [components_day setHour:components_time.hour];
    [components_day setMinute:components_time.minute];
    [components_day setSecond:components_time.second];
    NSDate *tomorrow = [cal dateFromComponents:components_day];
    return tomorrow;
}
+ (NSMutableArray*) getDateStartAndEnd:(NSDate*)date;
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:date];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:date options:0];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *endOfDay = [cal dateByAddingComponents:components toDate: today options:0];
    return [[NSMutableArray alloc] initWithObjects:today, endOfDay, nil];
}


+ (NSString *) downloadedURL:(NSString *)url name:(NSString *) name {
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        return localurl.absoluteString;
    }
    
    return nil;
}

+ (UIImage *)getUploadingUserImageFromImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    if(imageSize.width > imageSize.height){
        imageSize.width = imageSize.height;
    }else if(imageSize.height > imageSize.width){
        imageSize.height = imageSize.width;
    }
    UIGraphicsBeginImageContext(imageSize);
    CGRect drawRect = CGRectMake( - ((image.size.width - imageSize.width)/2.f),
                                 - ((image.size.height - imageSize.height)/2.f),
                                 image.size.width,
                                 image.size.height);
    [image drawInRect:drawRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *) getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]]; //create NSString object, that holds our exact path to the documents directory
    return  documentsDirectory;
}
+ (void) downloadFile:(NSString *)url name:(NSString *) name completionBlock:(void (^)(NSURL *downloadurl, NSData *data, NSError *err))completionBlock {
    NSURL *remoteurl = [NSURL URLWithString:url];
    NSString *fileName = name;
    if (name == nil) {
        fileName = [url lastPathComponent];
    }
    NSString *filePath = [[self getDocumentDirectory] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSURL *localurl = [NSURL fileURLWithPath:filePath];
        if (completionBlock)
            completionBlock(localurl, data, nil);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:remoteurl];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Download Error:%@",error.description);
            if (completionBlock)
                completionBlock(nil, data, error);
        } else if (data) {
            [data writeToFile:filePath atomically:YES];
            NSLog(@"File is saved to %@",filePath);
            
            NSURL *localurl = [NSURL fileURLWithPath:filePath];
            if (completionBlock)
                completionBlock(localurl, data, error);
        }
    }];
}
+ (NSString *)urlparseCDN:(NSString *)url
{
    NSArray *paths = [url pathComponents];
    
    if (paths && paths[1]) {
        NSArray *items = [paths[1] componentsSeparatedByString:@":"];
        if (items && [items[0] isEqualToString:PARSE_SERVER_BASE]) {
            NSInteger port = [items[1] integerValue] - PARSE_CDN_DECNUM;
            NSString *cdnURL = [NSString stringWithFormat:@"https://%@/process/%ld", PARSE_CDN_BASE, (long)port];
            
            for (int i=2; i<paths.count; i++) {
                cdnURL = [[cdnURL stringByAppendingString:@"/"] stringByAppendingString:paths[i]];
            }
            
            return cdnURL;
        }
    }
    
    return url;
}
+ (UIImage *)getUploadingImageFromImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    // dont' resize, use the original image. we can adjust this value of maxResolution like 1024, 768, 640  and more less than current value.
    CGFloat maxResolution = 320.f;
    if (image.size.width < maxResolution) {
        CGSize newSize = CGSizeMake(image.size.width, image.size.height);
        UIGraphicsBeginImageContext(newSize);
        // CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
        // CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, newSize.width, newSize.height));
        [image drawInRect:CGRectMake(0,
                                     0,
                                     image.size.width,
                                     image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        CGFloat rate = image.size.width / maxResolution;
        CGSize newSize = CGSizeMake(maxResolution, image.size.height / rate);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}
+ (NSString*) convertDateToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    return [formatter stringFromDate:date];
}
+ (NSString*) convertDateTimeToString:(NSDate*)date
{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    return [formatter stringFromDate:date];
}
+ (BOOL) isPhotoAvaileble {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted){
        return NO;
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        }];
        return YES;
    } else {
        return YES;
    }
}

+ (BOOL) isCameraAvailable {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
            return NO;
        }
        else if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:nil];
            return YES;
        }
        return YES;
    }
    else
        return YES;
}
@end
