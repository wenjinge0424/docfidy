//
//  DoctoProfileViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "DoctoProfileViewController.h"

@interface DoctoProfileViewController ()<CircleImageAddDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    PFUser * me;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_firstname;
@property (weak, nonatomic) IBOutlet UITextField *edt_lastname;
@property (weak, nonatomic) IBOutlet UITextField *edt_password;
@property (weak, nonatomic) IBOutlet UITextField *edt_email;
@property (weak, nonatomic) IBOutlet CircleImageView *imgThumb;

@end

@implementation DoctoProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edt_firstname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_firstname.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_lastname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_lastname.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_password.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.edt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.edt_email.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    self.imgThumb.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgThumb.layer.borderWidth = 1.f;
    self.imgThumb.delegate = self;
    
    [self showLoadingBar];
    me = [PFUser currentUser];
    [me fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self hideLoadingBar];
        me = (PFUser *) object;
        self.edt_firstname.text = me[PARSE_USER_FIRSTNAME];
        self.edt_lastname.text = me[PARSE_USER_LASTSTNAME];
        self.edt_password.text = me[PARSE_USER_PREVIEWPWD];
        self.edt_email.text = me[PARSE_USER_EMAIL];
        self.edt_email.userInteractionEnabled = NO;
        [Util setImage:self.imgThumb imgFile:(PFFile *)me[PARSE_USER_AVATAR] withDefault:[UIImage imageNamed:@"ic_default_avatar"]];
    }];
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
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSave:(id)sender {
    if (![Util isConnectableInternet]){
        [Util showAlertTitle:self title:@"Network Error" message:@"Please check your network state."];
        return;
    }
    if(self.edt_firstname.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input your first name."];
    }else if(self.edt_lastname.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input your last name."];
    }else if(self.edt_password.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Please input your password."];
    }else{
        [self showLoadingBar];
        NSString * previewPassword = me[PARSE_USER_PREVIEWPWD];
        NSString * newPassword = self.edt_password.text;
        BOOL needUpdatePWD = NO;
        if(![previewPassword isEqualToString:newPassword]){
            needUpdatePWD = YES;
        }
        me[PARSE_USER_FIRSTNAME] = self.edt_firstname.text;
        me[PARSE_USER_LASTSTNAME] = self.edt_lastname.text;
        me[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", self.edt_firstname.text, self.edt_lastname.text];
        if (hasPhoto){
            UIImage *profileImage = [Util getUploadingUserImageFromImage:self.imgThumb.image];
            NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
            me[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
        }
        [me saveInBackgroundWithBlock:^(BOOL success, NSError* error){
            if(!needUpdatePWD){
                [self hideLoadingBar];
                [Util showAlertTitle:self title:@"Edit Profile" message:@"Your profile changed." finish:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            }else{
                me.password = self.edt_password.text;
                me[PARSE_USER_PREVIEWPWD] = self.edt_password.text;
                [self showLoadingBar];
                [me saveInBackgroundWithBlock:^(BOOL success, NSError * error){
                    [PFUser logInWithUsernameInBackground:me.email password:me.password block:^(PFObject *object, NSError *error){
                        [self hideLoadingBar];
                        if(!error){
                            [Util setLoginUserName:[Util getLoginUserName] password:self.edt_password.text];
                            [Util showAlertTitle:self title:@"Success" message:@"Your profile successfully changed." finish:^{
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                        }else{
                            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                        }
                    }];
                }];
            }
        }];
    }
    
}
- (void)tapCircleImageView
{
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onChoosePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:actionsheet animated:YES completion:nil];
}
- (void)onChoosePhoto:(id)sender {
    if (![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    isGallery = YES;
    isCamera = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)onTakePhoto:(id)sender {
    if (![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
    isCamera = YES;
    isGallery = NO;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    hasPhoto = YES;
    [self.imgThumb setImage:[Util getUploadingUserImageFromImage:image]];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Camera"];
        return;
    }
}
@end
