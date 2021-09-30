//
//  MediaViewController.h
//  smallplayerbigplay
//
//  Created by Techsviewer on 7/26/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "BaseViewController.h"

@interface MediaViewController : BaseViewController
@property (strong, nonatomic) PFFile * pf_image;
@property (strong, nonatomic) PFFile *video;
@property (strong, nonatomic) UIImage *image;
@end
