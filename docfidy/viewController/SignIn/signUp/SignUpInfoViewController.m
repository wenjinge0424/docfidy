//
//  SignUpInfoViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "SignUpInfoViewController.h"

#import "SignUpPatternViewController.h"

@interface SignUpInfoViewController ()<CircleImageAddDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage * selectedImage;
    
    BOOL isCamera;
    BOOL isGallery;
    BOOL hasPhoto;
}
@property (weak, nonatomic) IBOutlet CircleImageView * imgThumb;
@property (weak, nonatomic) IBOutlet UITextField * txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField * txtLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation SignUpInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.txtFirstName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    self.txtLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.txtLastName.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    
    self.imgThumb.delegate = self;
    self.imgThumb.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgThumb.layer.borderWidth = 1.f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onNext:(id)sender {
    if (![self isValid]){
        return;
    }
    self.user[PARSE_USER_FIRSTNAME] = _txtFirstName.text;
    self.user[PARSE_USER_LASTSTNAME] = _txtLastName.text;
    self.user[PARSE_USER_FULLNAME] = [NSString stringWithFormat:@"%@ %@", _txtFirstName.text, _txtLastName.text];
    if (!hasPhoto){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        alert.customViewColor = MAIN_COLOR;
        alert.horizontalButtons = YES;
        [alert addButton:@"Yes" actionBlock:^(void) {
            [self gotoNext];
        }];
        [alert addButton:@"Upload Photo" actionBlock:^(void) {
            [self tapCircleImageView];
        }];
        [alert showError:@"Sign Up" subTitle:@"Are you sure you want to proceed without a profile photo?" closeButtonTitle:nil duration:0.0f];
    } else {
        UIImage *profileImage = [Util getUploadingImageFromImage:_imgThumb.image];
        NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
        self.user[PARSE_USER_AVATAR] = [PFFile fileWithData:imageData];
        [self gotoNext];
    }
}
- (void) gotoNext
{
    SignUpPatternViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpPatternViewController"];
    controller.runType = RUN_TYPE_SIGNUP;
    controller.user = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}
- (BOOL) isValid {
    [_txtFirstName resignFirstResponder];
    [_txtLastName resignFirstResponder];
    NSString *firstName = [Util trim:_txtFirstName.text];
    NSString *lastName = [Util trim:_txtLastName.text];
    _txtFirstName.text = firstName;
    _txtLastName.text = lastName;
    
    NSString * errorMessage = @"";
    if(firstName.length == 0){
        errorMessage = @"Please input first name.";
    }else if(firstName.length < 2){
        errorMessage = @"First name is too short.";
    }else if(firstName.length > 50){
        errorMessage = @"First name is too long.";
    }else if(lastName.length == 0){
        errorMessage = @"Please input last name.";
    }else if(lastName.length < 2){
        errorMessage = @"Last name is too short.";
    }else if(lastName.length > 50){
        errorMessage = @"Last name is too long.";
    }
    if(errorMessage.length > 0){
        [Util showAlertTitle:self title:@"Sign Up" message:errorMessage];
        return NO;
    }
    return YES;
}

- (void) tapCircleImageView {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self onTakePhoto:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Select from gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
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
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
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
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    UIImage *image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    [_imgThumb setImage:image];
    selectedImage = image;
    hasPhoto = YES;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (isGallery && ![Util isPhotoAvaileble]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Photo"];
        return;
    }
    if (isCamera && ![Util isCameraAvailable]){
        [Util showAlertTitle:self title:@"Error" message:@"Check your permissions in Settings > Privacy > Cameras"];
        return;
    }
}
@end
