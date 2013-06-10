//
//  KLNoteViewController.h
//  KLNoteController
//
//  Created by Kieran Lafferty on 2012-12-29.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KLNoteViewController;
@class KLControllerCard;
@protocol KLNoteViewControllerDataSource;
@protocol KLNoteViewControllerDelegate;

enum {
  KLControllerCardStateHiddenBottom,    //Card is hidden off screen (Below bottom of visible area)
  KLControllerCardStateHiddenTop,       //Card is hidden off screen (At top of visible area)
  KLControllerCardStateDefault,         //Default location for the card
  KLControllerCardStateFullScreen       //Highlighted location for the card 
};
typedef UInt32 KLControllerCardState;

enum {
    KLControllerCardPanGestureScopeNavigationBar,               // the pan gesture only works from the navigation bar
    KLControllerCardPanGestureScopeNavigationControllerView     // the pan gesture works on the whole card view
};
typedef UInt32 KLControllerCardPanGestureScope;

@protocol KLControllerCardDelegate <NSObject>
@optional
//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from KLControllerCardStateDefault to KLControllerCardStateDefault)
-(void) controllerCard:(KLControllerCard*)controllerCard didChangeToDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState;

//Called when user is panning and a the card has travelled X percent of the distance to the top - Used to redraw other cards during panning fanout
-(void) controllerCard:(KLControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage;
-(void) controllerCard:(KLControllerCard *)controllerCard willBeginPanningGesture:(UIPanGestureRecognizer*) gesture;
-(void) controllerCard:(KLControllerCard *)controllerCard didEndPanningGesture:(UIPanGestureRecognizer*) gesture;
@end

//KLController card encapsulates the UINavigationController handling all the resizing and state management for the view. It has no concept of the other cards or world outside of itself.
@interface KLControllerCard : UIView<UIGestureRecognizerDelegate>
{
    @private
    CGFloat originY;
    CGFloat scalingFactor;
}
//Avoid retain cycle by referencing parent as weak
@property (nonatomic, weak) KLNoteViewController* noteViewController;
@property (nonatomic, weak) id<KLControllerCardDelegate> delegate;
@property (nonatomic, strong) UIViewController* viewController; // viewController referenced controllerCard
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat panOriginOffset;
@property (nonatomic, assign) KLControllerCardState state;
//Gesture Recognizers

@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
-(id) initWithNoteViewController: (KLNoteViewController*) noteViewController
               andViewController:(UIViewController*) viewController;
-(void) toggleStateAnimated:(BOOL) animated;
-(void) setState:(KLControllerCardState) state animated:(BOOL) animated;
-(void) setYCoordinate:(CGFloat)yValue;
-(CGFloat) percentageDistanceTravelled;
@end

//KLNoteViewController manages the cards interfacing between the various cards
@interface KLNoteViewController : UIViewController  <KLControllerCardDelegate>

@property (nonatomic, weak) id<KLNoteViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<KLNoteViewControllerDelegate> delegate;

//Navigation bar properties
@property (nonatomic, strong) Class cardNavigationBarClass; //Use a custom class for the card navigation bar

//UIScrollView Subview in Controller
@property (nonatomic, assign) BOOL allowsInteractionInDefaultState;

//Layout properties
@property (nonatomic) CGFloat cardMinimizedScalingFactor;   //Amount to shrink each card from the previous one
@property (nonatomic) CGFloat cardMaximizedScalingFactor;   //Maximum a card can be scaled to
@property (nonatomic) CGFloat cardNavigationBarOverlap;     //Defines vertical overlap of each navigation toolbar. Slight hack that prevents rounding errors from showing the whitespace between navigation toolbars. Can be customized if require more/less packing of navigation toolbars

//Animation properties
@property (nonatomic) NSTimeInterval cardAnimationDuration;             //Amount of time for the animations to occur
@property (nonatomic) NSTimeInterval cardReloadHideAnimationDuration;
@property (nonatomic) NSTimeInterval cardReloadShowAnimationDuration;   

//Position for the stack of navigation controllers to originate at
@property (nonatomic) CGFloat cardVerticalOrigin;           //Vertical origin of the controller card stack. Making this value larger/smaller will make the card shift down/up.

//Corner radius properties
@property (nonatomic) CGFloat cardCornerRadius;

//Shadow Properties - Note : Disabling shadows greatly improves performance and fluidity of animations
@property (nonatomic) BOOL cardShadowEnabled;
@property (nonatomic) UIColor* cardShadowColor;
@property (nonatomic) CGSize cardShadowOffset;
@property (nonatomic) CGFloat cardShadowRadius;
@property (nonatomic) CGFloat cardShadowOpacity;

//Gesture properties
@property (nonatomic) KLControllerCardPanGestureScope cardPanGestureScope;
@property (nonatomic) BOOL cardEnablePressGesture;
@property (nonatomic) NSInteger cardMinimumTapsRequired;

//Autoresizing mask used for the card controller
@property (nonatomic) UIViewAutoresizing cardAutoresizingMask;

//KLControllerCards in an array. Object at index 0 will appear at bottom of the stack, and object at position (size-1) will appear at the top
@property (nonatomic, strong) NSArray* controllerCards;

//Repopulates all data for the controllerCards array
-(void) reloadData;
-(void) reloadDataAnimated:(BOOL) animated;

//Helpers for getting information about the controller cards
-(NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView;
-(UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerAtIndex:(NSInteger) index;
-(NSInteger) indexForControllerCard: (KLControllerCard*) controllerCard;
-(void) noteViewController: (KLNoteViewController*) noteViewController didUpdateControllerCard:(KLControllerCard*)controllerCard toDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState;
@end
@protocol   KLNoteViewControllerDelegate <NSObject>
@optional
//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from KLControllerCardStateDefault to KLControllerCardStateDefault)
-(void) noteViewController: (KLNoteViewController*) noteViewController didUpdateControllerCard:(KLControllerCard*)controllerCard toDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState;
@end
@protocol   KLNoteViewControllerDataSource <NSObject>
@required
//Called when the NoteViewController needs to know how many controller cards to expect
- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView;
//Called to populate the controllerCards array - Automatically maps the UINavigationController to KLControllerCard and adds to array
- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerAtIndex:(NSInteger) index;
@end