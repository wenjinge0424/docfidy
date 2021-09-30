//
//  EditNoteViewController.m
//  docfidy
//
//  Created by Techsviewer on 1/30/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "EditNoteViewController.h"

@interface EditNoteViewController ()
{
    NSMutableArray * linkedPatients;
}
@property (weak, nonatomic) IBOutlet UITextView *txt_note;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;

@end

@implementation EditNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.runTypeMode == APP_RUN_MODE_EDIT){
        self.lbl_title.text = @"Edit Note";
        self.txt_note.text = self.noteObject[PARSE_NOTE_DESCRIPTION];
        [self.btn_delete setHidden:NO];
    }else{
        self.lbl_title.text = @"New Note";
        [self.btn_delete setHidden:YES];
        if(!self.relationPatient){
            [self fetchData];
        }
    }
}
- (void) fetchData
{
    PFUser * me = [PFUser currentUser];
    [self showLoadingBar];
    linkedPatients = [NSMutableArray new];
    PFQuery * query1  = [PFQuery queryWithClassName:PARSE_TABLE_PATIENTS];
    [query1 whereKey:PARSE_PATIENTS_DOCTOR containedIn:@[me]];
    
    PFQuery * query2  = [PFQuery queryWithClassName:PARSE_TABLE_PATIENTS];
    [query1 whereKey:PARSE_PATIENTS_NURSE containedIn:@[me]];
    
    PFQuery * query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
        [self hideLoadingBar];
        if (error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        } else {
            for (int i=0;i<array.count;i++){
                PFObject  *obj = [array objectAtIndex:i];
                [linkedPatients addObject:obj];
            }
        }
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
    if(self.txt_note.text.length == 0){
        [Util showAlertTitle:self title:@"Error" message:@"Pleae enter note."];
    }else{
        if(self.runTypeMode == APP_RUN_MODE_EDIT){
            [self showLoadingBar];
            self.noteObject[PARSE_NOTE_DESCRIPTION] = self.txt_note.text;
            [self.noteObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self hideLoadingBar];
                if(error){
                    [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                }else{
                    [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }];
        }else{
            if(self.relationPatient){
                [self showLoadingBar];
                PFObject * noteObj = [PFObject objectWithClassName:PARSE_TABLE_NOTE];
                noteObj[PARSE_NOTE_PATIENT] = self.relationPatient;
                noteObj[PARSE_NOTE_OWNER] = [PFUser currentUser];
                noteObj[PARSE_NOTE_DESCRIPTION] = self.txt_note.text;
                [noteObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [self hideLoadingBar];
                    if(error){
                        [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
                    }else{
                        [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                }];
            }else{
                if(linkedPatients && linkedPatients.count > 0){
                    [self showLoadingBar];
                    for(PFObject * patient in linkedPatients){
                        PFObject * noteObj = [PFObject objectWithClassName:PARSE_TABLE_NOTE];
                        noteObj[PARSE_NOTE_PATIENT] = patient;
                        noteObj[PARSE_NOTE_OWNER] = [PFUser currentUser];
                        noteObj[PARSE_NOTE_DESCRIPTION] = self.txt_note.text;
                        [noteObj saveInBackground];
                    }
                    [self hideLoadingBar];
                    [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
            }
        }
    }
}
- (IBAction)onDelete:(id)sender {
    [self showLoadingBar];
    [self.noteObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self hideLoadingBar];
        if(error){
            [Util showAlertTitle:self title:@"Error" message:[error localizedDescription]];
        }else{
            [Util showAlertTitle:self title:@"" message:@"Success" finish:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

@end
