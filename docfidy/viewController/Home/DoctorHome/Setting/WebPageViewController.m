//
//  WebPageViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/31/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "WebPageViewController.h"

@interface WebPageViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UIWebView *m_webView;

@end

@implementation WebPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"html"];
    if(self.runMode == 0){
        self.lbl_title.text = @"Privacy Policy";
        htmlFile = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"html"];
    }else{
        self.lbl_title.text = @"Terms and Conditions";
    }
    self.m_webView.delegate = self;
    NSURL *instructionsURL = [NSURL fileURLWithPath:htmlFile];
    [self.m_webView loadRequest:[NSURLRequest requestWithURL:instructionsURL]];
    [self showLoadingBar];
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
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingBar];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none'"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none'"];
}
@end
