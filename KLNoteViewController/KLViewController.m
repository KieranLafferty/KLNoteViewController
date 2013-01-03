//
//  KLViewController.m
//  KLNoteViewController
//
//  Created by Kieran Lafferty on 2012-12-29.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import "KLViewController.h"
@interface KLViewController ()

@end

@implementation KLViewController

- (void)viewDidLoad
{

	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-dark-gray-tex.png"]]];
    
    //Initialize the controller data
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"NavigationControllerData"
                                                          ofType: @"plist"];
    // Build the array from the plist
    self.navigationControllers = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView {
    return  [self.navigationControllers count];
}
- (UINavigationController *)noteView:(KLNoteViewController*)noteView controllerCardForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get the relevant data for the navigation controller
    NSDictionary* navDict = [self.navigationControllers objectAtIndex: indexPath.row];
    
    //Initialize a blank uiviewcontroller for display purposes
    UIViewController* viewController = [[UIViewController alloc] init];
    [viewController.view setBackgroundColor: [UIColor colorWithRed: 225/255.0
                                                             green: 225/255.0
                                                              blue: 225/255.0
                                                             alpha: 1.0]];
    [viewController setTitle: [navDict objectForKey:@"title"]];
    
    
    //Initialize the nav controller with the view controller
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController: viewController];
    [navController.navigationBar setBackgroundImage: [UIImage imageNamed:[navDict objectForKey:@"image"]]
                                      forBarMetrics: UIBarMetricsDefault];

    //Return a blank navigationcontroller
    return navController;
}

@end
