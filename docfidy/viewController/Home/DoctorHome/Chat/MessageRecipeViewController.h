//
//  MessageRecipeViewController.h
//  docfidy
//
//  Created by Techsviewer on 2/14/19.
//  Copyright © 2019 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MessageRecipeViewControllerDelegate
- (void) didmissWithArray:(NSMutableArray*)array;
@end

@interface MessageRecipeViewController : BaseViewController
@property (nonatomic, retain) id<MessageRecipeViewControllerDelegate>delegate;
@property (nonatomic, retain) NSMutableArray * alreadySelectedDoctors;
@property (nonatomic, retain) PFObject * messageRoomObj;
@end

NS_ASSUME_NONNULL_END
