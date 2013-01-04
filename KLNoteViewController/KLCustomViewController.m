//
//  KLCustomViewController.m
//  KLNoteViewController
//
//  Created by Kieran Lafferty on 2013-01-03.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//

#import "KLCustomViewController.h"

@implementation KLCustomViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:[self.info objectForKey:@"image"]]
                                                  forBarMetrics: UIBarMetricsDefault];
	[self.navigationItem setTitle:[self.info objectForKey:@"title"]];
}

@end
