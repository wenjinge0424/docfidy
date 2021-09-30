//
//  CheckPatternViewController.m
//  docfidy
//
//  Created by Techsviewer on 2/18/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "CheckPatternViewController.h"
#import "ioPatternLock.h"
#import "LoginViewController.h"

@interface CheckPatternViewController ()<IOPatternLockDelegate>
{
    int errorCount;
}
@property (weak, nonatomic) IBOutlet UIView *view_actionContainer;
@end

@implementation CheckPatternViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    errorCount = 0;
    IOPatternLockView * actionView = [[IOPatternLockView alloc] initWithFrame:self.view_actionContainer.bounds];
    actionView.column = 3;
    actionView.row = 3;
    actionView.minimumNumberOfSelections = 2;
    actionView.circleSpace = 20;
    actionView.innerCirclePadding = 15;
    actionView.lineWidth = 4;
    actionView.delegate = self;
    actionView.backgroundColor = [UIColor whiteColor];
    actionView.borderColor = [UIColor lightGrayColor];
    actionView.innerCircleColor = [UIColor lightGrayColor];
    actionView.lineColor = [UIColor darkGrayColor];
    actionView.activeBorderColor = [UIColor blackColor];
    actionView.activeInnerCircleColor = [UIColor blackColor];
    [self.view_actionContainer addSubview:actionView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSString*) convertToString:(NSArray<NSNumber *> *)selectedPatterns
{
    NSString * string = @"[";
    for(NSNumber* subNum in selectedPatterns){
        string = [string stringByAppendingFormat:@"%@-", [subNum stringValue]];
    }
    string = [string substringToIndex:string.length - 1];
    string = [string stringByAppendingFormat:@"]"];
    return string;
}
- (void)ioPatternLockView:(IOPatternLockView *)patternLockView patternCompleted:(NSArray<NSNumber *> *)selectedPatterns
{
    NSString * patternStr = [self convertToString:selectedPatterns];
    NSString * recentPattern = [Util getUnlockPattern];
    if([patternStr isEqualToString:recentPattern]){
        LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController setViewControllers:@[controller] animated:NO];
    }else{
        errorCount ++;
        if(errorCount < 4){
            [Util showAlertTitle:self title:@"Error" message:@"You have incorrectly drawn your unlock pattern. Try again."];
        }else{
            [Util setLoginUserName:@"" password:@""];
            [Util setUnlockPattern:@""];
            LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController setViewControllers:@[controller] animated:NO];
        }
    }
}
- (void)ioPatternLockView:(IOPatternLockView *)patternLockView patternCompletedWithError:(NSError *)error
{
    
}
@end
