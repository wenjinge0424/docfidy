//
//  Onboard2ViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/26/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "Onboard2ViewController.h"
#import "Onboard3ViewController.h"
#import "LoginViewController.h"

@interface Onboard2ViewController ()

@end

@implementation Onboard2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer * swipleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipleft];
    
    UISwipeGestureRecognizer * swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipRight];
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
    Onboard3ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard3ViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)onSignIn:(id)sender {
    LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)swipeLeft:(UISwipeGestureRecognizer*)gesture
{
    [self onNext:nil];
}
- (void)swipeRight:(UISwipeGestureRecognizer*)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
