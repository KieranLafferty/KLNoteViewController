//
//  KLViewController.h
//  KLNoteViewController
//
//  Created by Kieran Lafferty on 2012-12-29.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLNoteViewController.h"

@interface KLViewController : KLNoteViewController
- (IBAction)reloadCardData:(id)sender;
@property (nonatomic, strong) NSArray* viewControllerData;
@end
