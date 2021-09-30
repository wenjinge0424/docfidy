//
//  BaseViewController.m
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/19/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"
#import "ChattingViewController.h"
//#import "MediaViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*- (void) onPlayVideo:(PFFile*)video
{
    if(video){
        MediaViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediaViewController"];
        vc.video = video;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void) onShowPFImage:(PFFile*)image
{
    if(image){
        MediaViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MediaViewController"];
        vc.pf_image = image;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)onMessages:(PFUser*)owner {
    ChatViewController * vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    PFUser * me = [PFUser currentUser];
    BOOL isMe = NO;
    if([me.objectId isEqualToString:owner.objectId])
        isMe = YES;
    if (!isMe){
        if (![Util isConnectableInternet]){
            [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
            return;
        }
        vc.toUser = owner;
        PFQuery *query1 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query1 whereKey:PARSE_ROOM_SENDER equalTo:[PFUser currentUser]];
        [query1 whereKey:PARSE_ROOM_RECEIVER equalTo:owner];
        
        PFQuery *query2 = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
        [query2 whereKey:PARSE_ROOM_RECEIVER equalTo:[PFUser currentUser]];
        [query2 whereKey:PARSE_ROOM_SENDER equalTo:owner];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        [queries addObject:query1];
        [queries addObject:query2];
        PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
        //        [query whereKey:PARSE_ROOM_ENABLED equalTo:@YES];
        [query includeKey:PARSE_ROOM_RECEIVER];
        [query includeKey:PARSE_ROOM_SENDER];
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object){
                [self hideLoadingBar];
                if ([object[PARSE_ROOM_ENABLED] boolValue]){
                    
                } else {
                    object[PARSE_ROOM_ENABLED] = @YES;
                    [object saveInBackground];
                }
                vc.room = object;
                vc.toUser = owner;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                PFObject *obj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
                obj[PARSE_ROOM_SENDER] = [PFUser currentUser];
                obj[PARSE_ROOM_RECEIVER] = owner;
                obj[PARSE_ROOM_ENABLED] = @YES;
                obj[PARSE_ROOM_LAST_MESSAGE] = @"";
                obj[PARSE_ROOM_IS_READ] = @YES;
                [obj saveInBackgroundWithBlock:^(BOOL succeed, NSError *err){
                    [self hideLoadingBar];
                    vc.room = obj;
                    vc.toUser = owner;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
            }
        }];
    } else {
//        [self.navigationController pushViewController:vc animated:YES];
    }
    
}*/
- (NSString *) getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}
- (void) onShareAction:(PFObject*)post
{
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    BOOL isVideo = [post[PARSE_POST_IS_VIDEO] boolValue];
    if (!isVideo){
        PFFile *file = post[PARSE_POST_IMAGE];
        NSString *link = file.url;
        [activityItems addObject:link];
        [self showLoadingBar];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (error){
                [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
            } else {
                UIImage *img = [UIImage imageWithData:data];
                [activityItems addObject:img];
                UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                activityViewControntroller.excludedActivityTypes = @[];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    activityViewControntroller.popoverPresentationController.sourceView = self.view;
                    activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                }
                
                [self presentViewController:activityViewControntroller animated:YES completion:nil];
                [self hideLoadingBar];
            }
        }];
    } else {
        PFFile *file = (PFFile *)post[PARSE_POST_VIDEO];
        if (!file){
            return;
        }
        NSString* link = file.url;
        [activityItems addObject:link];
        
        NSString *docPath = [self getDocumentDirectoryPath];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", docPath, file.name];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists){
            [activityItems addObject:[NSURL fileURLWithPath:filePath]];
            UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activityViewControntroller.excludedActivityTypes = @[];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                activityViewControntroller.popoverPresentationController.sourceView = self.view;
                activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
            }
            
            [self presentViewController:activityViewControntroller animated:YES completion:nil];
        } else {
            [self showLoadingBar];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                [self hideLoadingBar];
                if (error){
                    NSLog(@"Error get Video Data from Server");
                } else {
                    [data writeToFile:filePath atomically:YES];
                    [activityItems addObject:[NSURL fileURLWithPath:filePath]];
                    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                    activityViewControntroller.excludedActivityTypes = @[];
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        activityViewControntroller.popoverPresentationController.sourceView = self.view;
                        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                    }
                    
                    [self presentViewController:activityViewControntroller animated:YES completion:nil];
                }
            }];
        }
    }
}
- (PFUser*) getUserFromId:(NSString*)userId inArray:(NSMutableArray*)userArray
{
    for(PFUser * user in userArray){
        if([user.objectId isEqualToString:userId]){
            return user;
        }
    }
    return nil;
}

- (void) onSendMessageTo:(PFUser *) user inPatient:(PFObject*)patient
{
    [self showLoadingBar];
    PFUser * me = [PFUser currentUser];
    PFQuery * query = [PFQuery queryWithClassName:PARSE_TABLE_CHAT_ROOM];
    [query whereKey:PARSE_ROOM_PARTICIPANTS containedIn:@[me]];
    [query whereKey:PARSE_ROOM_PARTICIPANTS containedIn:@[user]];
    [query whereKey:PARSE_ROOM_PATIENT equalTo:patient];
    [query whereKey:PARSE_ROOM_ISGROUP notEqualTo:[NSNumber numberWithBool:YES]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object){
            [self hideLoadingBar];
            ChattingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChattingViewController"];
            controller.mesageChannelInfo = object;
            controller.mesageReceiverInfo = user;
            controller.linkedPatientInfo = patient;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            PFObject * channelObj = [PFObject objectWithClassName:PARSE_TABLE_CHAT_ROOM];
            channelObj[PARSE_ROOM_IS_READ] = [NSNumber numberWithBool:NO];
            channelObj[PARSE_ROOM_PARTICIPANTS] = @[me, user];
            channelObj[PARSE_ROOM_PATIENT] = patient;
            channelObj[PARSE_ROOM_ISGROUP] = [NSNumber numberWithBool:NO];
            [channelObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self hideLoadingBar];
                ChattingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChattingViewController"];
                controller.mesageChannelInfo = channelObj;
                controller.mesageReceiverInfo = user;
                controller.linkedPatientInfo = patient;
                [self.navigationController pushViewController:controller animated:YES];
            }];
        }
    }];
}
- (void) showLoadingBar
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
- (void) hideLoadingBar
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
