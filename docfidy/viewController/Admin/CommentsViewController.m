//
//  CommentsViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/28/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"

@interface CommentsViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *heightArray;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_desc;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    heightArray = [[NSMutableArray alloc] init];
    self.lbl_title.text = [NSString stringWithFormat:@"%@ %@", self.patientObj[PARSE_PATIENTS_FIRSTNAME], self.patientObj[PARSE_PATIENTS_LASTNAME]];
    self.lbl_desc.text = self.patientObj[PARSE_PATIENTS_RECORDNUMBER];
    
    [self fetchData];
}
- (void) fetchData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        heightArray = [[NSMutableArray alloc] init];
        for (int i=0;i<self.noteArray.count;i++){
            [heightArray addObject:[NSString stringWithFormat:@"%f", [self getHeight:i]]];
        }
        self.tbl_data.delegate = self;
        self.tbl_data.dataSource = self;
        [self.tbl_data reloadData];
    });
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.noteArray.count;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    if(cell){
        PFObject *object = self.noteArray[indexPath.row];
        PFUser *user = object[PARSE_NOTE_OWNER];
        cell.lblName.text = user[PARSE_USER_FULLNAME];
        cell.txtComment.text = object[PARSE_NOTE_DESCRIPTION];
        cell.lblDate.text = [object.createdAt formattedAsTimeAgo];
    }
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[heightArray objectAtIndex:indexPath.row] floatValue];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (CGFloat) getHeight:(NSInteger)row {
    UITextView *textView = [[UITextView alloc] init];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(265, 40);
    textView.frame = newFrame;
    
    PFObject *feed = [self.noteArray objectAtIndex:row];
    NSString *text = feed[PARSE_NOTE_DESCRIPTION];
    textView.text = text;
    
    textView.translatesAutoresizingMaskIntoConstraints = YES;
    [textView sizeToFit];
    textView.scrollEnabled =NO;
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize new = [self calculateHeightForString:text];
    CGRect newFrame1 = textView.frame;
    newFrame.size = CGSizeMake(fixedWidth, new.height);
    textView.frame = newFrame1;
    
    return 60 + new.height;
}
//our helper method
- (CGSize)calculateHeightForString:(NSString *)str
{
    CGSize size = CGSizeZero;
    
    UIFont *labelFont = [UIFont systemFontOfSize:12.0f];
    NSDictionary *systemFontAttrDict = [NSDictionary dictionaryWithObject:labelFont forKey:NSFontAttributeName];
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:str attributes:systemFontAttrDict];
    CGRect rect = [message boundingRectWithSize:(CGSize){320, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];//you need to specify the some width, height will be calculated
    size = CGSizeMake(rect.size.width, rect.size.height + 5); //padding
    
    return size;
    
}
@end
