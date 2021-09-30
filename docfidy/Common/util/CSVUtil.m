//
//  CSVUtil.m
//  docfidy
//
//  Created by Techsviewer on 3/21/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "CSVUtil.h"
#import "Utils.h"

@implementation CPTCode
@end

@implementation DIAGNOSISCode
@end


@implementation CSVUtil
- (NSMutableArray*) getCPTCodes
{
    NSMutableArray * dataArray = [NSMutableArray new];
    NSError * error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cpt" ofType:@"csv"];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* rows = [fileContent componentsSeparatedByString:@"\n"];
    for(NSString * subStr in rows){
        NSArray* columns = [subStr componentsSeparatedByString:@","];
        CPTCode * code = [CPTCode new];
        code.category = columns[0];
        if(columns.count > 1){
            code.code = columns[1];
        }else{
            code.code = @"";
        }
        if(columns.count > 2)
            code.desc = columns[2];
        [dataArray addObject:code.code];
    }
    return dataArray;
}
- (NSMutableArray*) getDiagnosisCodes
{
    NSMutableArray * dataArray = [NSMutableArray new];
    NSError * error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"codes" ofType:@"csv"];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* rows = [fileContent componentsSeparatedByString:@"\n"];
    for(NSString * subStr in rows){
        NSArray* columns = [subStr componentsSeparatedByString:@","];
        DIAGNOSISCode * code = [DIAGNOSISCode new];
        code.category = columns[0];
        if(columns.count > 1){
            code.number = columns[1];
        }else{
            code.number = @"";
        }
        if(columns.count > 2){
            code.code = columns[2];
        }else{
            code.code = @"";
        }
        [dataArray addObject:code.code];
    }
    return dataArray;
}
@end
