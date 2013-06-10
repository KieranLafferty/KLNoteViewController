KLNoteViewController
=======

<img src="https://raw.github.com/KieranLafferty/KLNoteViewController/master/KLNoteViewController/Images/iPhoneScreenshot.png" width="50%"/>

A control that organizes multiple navigation controllers in a stack inspired by Evernote 5.0 app

Note: KLNoteViewController is intended for use with portrait orientation on iPhone/iPad/iPod Touch.

[Check out the Demo](http://www.youtube.com/watch?v=igh9bAyjZrM&feature=youtube_gdata_player) *Excuse the graphics glitches and lag due to my slow computer.*

<!-- MacBuildServer Install Button -->
<div class="macbuildserver-block">
    <a class="macbuildserver-button" href="http://macbuildserver.com/project/github/build/?xcode_project=KLNoteViewController.xcodeproj&amp;target=KLNoteViewController&amp;repo_url=https%3A%2F%2Fgithub.com%2FKieranLafferty%2FKLNoteViewController&amp;build_conf=Release" target="_blank"><img src="http://com.macbuildserver.github.s3-website-us-east-1.amazonaws.com/button_up.png"/></a><br/><sup><a href="http://macbuildserver.com/github/opensource/" target="_blank">by MacBuildServer</a></sup>
</div>
<!-- MacBuildServer Install Button -->


## Installation ##

Drag the included <code>KLNoteViewController.h, KLNoteViewController.m</code> files into your project. Then, include the following frameworks under *Link Binary With Libraries*:

* QuartzCore.framework

## Usage ##
Import the header file and declare your controller to subclass KLNoteViewController 
	#import "KLNoteViewController.h"
	
	@interface KLRootViewController : KLNoteViewController

OR, Import the header file and declare your controller to conform to KLNoteViewControllerDataSource and KLNoteViewControllerDelegate

	#import "KLNoteViewController.h"

	@interface KLRootViewController : UIViewController <KLNoteViewControllerDataSource, KLNoteViewControllerDelegate>
	@property(nonatomic, strong) KLNoteViewController* noteViewController;

Implement the required methods of the data source 

	- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView;
	- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;
	

Example - Should be changed to suit your needs

	- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView {
	    return  [self.viewControllers count];
	}
	- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath {
	    //Get the relevant data for the navigation controller
	    NSDictionary* navDict = [self.navigationControllers objectAtIndex: indexPath.row];

	    //Initialize a blank uiviewcontroller for display purposes
	    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];

	    KLCustomViewController* viewController = [st instantiateViewControllerWithIdentifier:@"RootViewController"];
	    [viewController setInfo: navDict];

	    //Return the custom view controller
	    return viewController;
	}

Implement the optional delegate method to be notified when a card changes state

	//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from KLControllerCardStateDefault to KLControllerCardStateDefault)
	-(void) noteViewController: (KLNoteViewController*) noteViewController didUpdateControllerCard:(KLControllerCard*)controllerCard toDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState;

## Config ##
The visual appearance can be tweaked by changing the constants in <code>KLNoteViewController.m</code>:

	//Layout properties
	#define kDefaultMinimizedScalingFactor 0.98     //Amount to shrink each card from the previous one
	#define kDefaultMaximizedScalingFactor 1.00     //Maximum a card can be scaled to
	#define kDefaultNavigationBarOverlap 0.90       //Defines vertical overlap of each navigation toolbar. Slight hack that prevents rounding errors from showing the whitespace between navigation toolbars. Can be customized if require more/less packing of navigation toolbars

	//Animation properties
	#define kDefaultAnimationDuration 0.3           //Amount of time for the animations to occur
	#define kDefaultReloadHideAnimationDuration 0.4
	#define kDefaultReloadShowAnimationDuration 0.6

	//Position for the stack of navigation controllers to originate at
	#define kDefaultVerticalOrigin 100              //Vertical origin of the controller card stack. Making this value larger/smaller will make the card shift down/up.

	//Corner radius properties
	#define kDefaultCornerRadius 5.0

	//Shadow Properties - Note : Disabling shadows greatly improves performance and fluidity of animations
	#define kDefaultShadowEnabled YES
	#define kDefaultShadowColor [UIColor blackColor]
	#define kDefaultShadowOffset CGSizeMake(0, -5)
	#define kDefaultShadowRadius kDefaultCornerRadius
	#define kDefaultShadowOpacity 0.60

	//Gesture properties
	#define kDefaultMinimumPressDuration 0.2


## Contact ##

* [@kieran_lafferty](https://twitter.com/kieran_lafferty) on Twitter
* [@kieranlafferty](https://github.com/kieranlafferty) on Github
* <a href="mailTo:kieran.lafferty@gmail.com">kieran.lafferty [at] gmail [dot] com</a>

## License ##

Copyright (c) 2012 Kieran Lafferty

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.