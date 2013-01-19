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

@protocol KLControllerCardDelegate <NSObject>
@optional
//Called on any time a state change has occured - even if a state has changed to itself - (i.e. from KLControllerCardStateDefault to KLControllerCardStateDefault)
-(void) controllerCard:(KLControllerCard*)controllerCard didChangeToDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState;

//Called when user is panning and a the card has travelled X percent of the distance to the top - Used to redraw other cards during panning fanout
-(void) controllerCard:(KLControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage;
@end

//KLController card encapsulates the UINavigationController handling all the resizing and state management for the view. It has no concept of the other cards or world outside of itself.
@interface KLControllerCard : UIView
{
    @private
    CGFloat originY;
    CGFloat scalingFactor;
    NSInteger index;
}
@property (nonatomic, strong) UINavigationController* navigationController;
@property (nonatomic, strong) KLNoteViewController* noteViewController;
@property (nonatomic, strong) id<KLControllerCardDelegate> delegate;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat panOriginOffset;
@property (nonatomic) KLControllerCardState state;
-(id) initWithNoteViewController: (KLNoteViewController*) noteView navigationController:(UINavigationController*) navigationController index:(NSInteger) index;
-(void) setState:(KLControllerCardState) state animated:(BOOL) animated;
-(void) setYCoordinate:(CGFloat)yValue;
-(CGFloat) percentageDistanceTravelled;
@end

//KLNoteViewController manages the cards interfacing between the various cards
@interface KLNoteViewController : UIViewController  <KLControllerCardDelegate> {
    NSInteger totalCards;
}
@property (nonatomic, assign) id<KLNoteViewControllerDataSource> dataSource;
@property (nonatomic, assign) id<KLNoteViewControllerDelegate> delegate;

//KLControllerCards in an array. Object at index 0 will appear at bottom of the stack, and object at position (size-1) will appear at the top
@property (nonatomic, strong) NSArray* controllerCards;

//Repopulates all data for the controllerCards array
-(void) reloadData;
-(void) reloadDataAnimated:(BOOL) animated;

//Helpers for getting information about the controller cards
-(NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView;
-(UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath*) indexPathForControllerCard: (KLControllerCard*) controllerCard;
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
- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerForRowAtIndexPath:(NSIndexPath *)indexPath;
@end