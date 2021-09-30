//
//  CSVUtil.h
//  docfidy
//
//  Created by Techsviewer on 3/21/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CPTCode : NSObject
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@end

@interface DIAGNOSISCode : NSObject
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@end



@interface CSVUtil : NSObject
- (NSMutableArray*) getCPTCodes;
- (NSMutableArray*) getDiagnosisCodes;
@end

NS_ASSUME_NONNULL_END
