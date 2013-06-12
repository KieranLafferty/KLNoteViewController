//
//  KLNoteViewController.m
//  KLNoteController
//
//  Created by Kieran Lafferty on 2012-12-29.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import "KLNoteViewController.h"
#import <QuartzCore/QuartzCore.h>

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
#define kDefaultNumberOfTapsRequired 2

//Distance to top of screen that must be passed in order to toggle full screen state transition
#define kFullScreenDistanceThreshold 44.0
#define kAllowsInteractionInDefaultState NO

@interface KLNoteViewController ()
- (void)configureDefaultSettings;
@property (nonatomic, strong) NSMutableArray* viewControllers;

//Drawing information for the navigation controllers
- (CGFloat) defaultVerticalOriginForControllerCard: (KLControllerCard*) controllerCard atIndex:(NSInteger) index;
- (CGFloat) defaultVerticalOriginForControllerCard: (KLControllerCard*) controllerCard;
- (CGFloat) scalingFactorForIndex: (NSInteger) index;
- (void) removeControllerCardFromSuperView;

//Controller Card groups
- (NSArray*) controllerCardsBelowCard:(KLControllerCard*) card;
- (NSArray*) controllerCardsAboveCard:(KLControllerCard*) card;
- (NSArray*) controllerCardsWithoutCard:(KLControllerCard*) card;

@end

@implementation KLNoteViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    [self configureDefaultSettings];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    [self configureDefaultSettings];
    
    return self;
}

- (void)configureDefaultSettings {
    _viewControllers = [[NSMutableArray alloc] initWithCapacity: [self.dataSource numberOfControllerCardsInNoteView:self]];
    
    self.allowsInteractionInDefaultState = kAllowsInteractionInDefaultState;
    self.cardNavigationBarClass = [UINavigationBar class];
    
    self.cardMinimizedScalingFactor = kDefaultMinimizedScalingFactor;
    self.cardMaximizedScalingFactor = kDefaultMaximizedScalingFactor;
    self.cardNavigationBarOverlap = kDefaultNavigationBarOverlap;
    
    self.cardAnimationDuration = kDefaultAnimationDuration;
    self.cardReloadHideAnimationDuration = kDefaultReloadHideAnimationDuration;
    self.cardReloadShowAnimationDuration = kDefaultReloadShowAnimationDuration;
    
    self.cardVerticalOrigin = kDefaultVerticalOrigin;
    
    self.cardCornerRadius = kDefaultCornerRadius;
    
    self.cardShadowEnabled = kDefaultShadowEnabled;
    self.cardShadowColor = kDefaultShadowColor;
    self.cardShadowOffset = kDefaultShadowOffset;
    self.cardShadowRadius = kDefaultShadowRadius;
    self.cardShadowOpacity = kDefaultShadowOpacity;
    
    self.cardPanGestureScope = KLControllerCardPanGestureScopeNavigationBar;
    self.cardEnablePressGesture = YES;
    self.cardMinimumTapsRequired = kDefaultNumberOfTapsRequired;
    
    self.cardAutoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |
                                 UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleLeftMargin |
                                 UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleWidth);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Populate the navigation controllers to the controller stack
    [self reloadData];
}

#pragma Drawing Methods - Used to position and present the navigation controllers on screen
- (NSInteger) indexForControllerCard: (KLControllerCard*) controllerCard {
    return  [self.viewControllers indexOfObject: controllerCard.viewController];
}
- (CGFloat) defaultVerticalOriginForControllerCard: (KLControllerCard*) controllerCard {
    return  [self defaultVerticalOriginForControllerCard: controllerCard
                                                 atIndex: [self indexForControllerCard: controllerCard]];
}
- (CGFloat) defaultVerticalOriginForControllerCard: (KLControllerCard*) controllerCard atIndex:(NSInteger) index {
    //Sum up the shrunken size of each of the cards appearing before the current index
    CGFloat originOffset = 0;
    for (int i = 0; i < index; i ++) {
        CGFloat scalingFactor = [self scalingFactorForIndex: i];
        originOffset += scalingFactor * kFullScreenDistanceThreshold* self.cardNavigationBarOverlap;
    }
    
    //Position should start at self.cardVerticalOrigin and move down by size of nav toolbar for each additional nav controller
    return roundf(self.cardVerticalOrigin + originOffset);
}

- (CGFloat) scalingFactorForIndex: (NSInteger) index {
    //Items should get progressively smaller based on their index in the navigation controller array
    return  powf(self.cardMinimizedScalingFactor, ([self numberOfControllerCardsInNoteView:self] - index));
}

- (void) reloadData {
    
    self.controllerCards = nil;
    [self.viewControllers removeAllObjects];
    //Get the number of navigation  controllers to expect
    
    //For each expected controller grab from the instantiating class and populate into local controller stack
    NSMutableArray* cardControllers = [[NSMutableArray alloc] initWithCapacity: [self numberOfControllerCardsInNoteView:self]];
    
    //First populate child view controllers
    for (NSInteger count = 0; count < [self numberOfControllerCardsInNoteView:self]; count++) {
        UIViewController* viewController = [self noteView: self
                                    viewControllerAtIndex: count];
        if (![self.viewControllers containsObject: viewController]) {
            [self addChildViewController: viewController];
            [self.viewControllers addObject: viewController];
        }
    }
    //For each child view controller create a controller card
    for (UIViewController* currentViewController in self.viewControllers) {
        KLControllerCard* controllerCard = [[KLControllerCard alloc] initWithNoteViewController: self
                                                                              andViewController: currentViewController];

        [controllerCard setDelegate: self];
        [cardControllers addObject: controllerCard];
        [currentViewController willMoveToParentViewController: self];
        [self.view addSubview: controllerCard];
        //As child controller will call the delegate methods for UIViewController
        [currentViewController didMoveToParentViewController: self];
        [controllerCard setState:KLControllerCardStateDefault
                        animated:NO];
    }
    
    self.controllerCards = [NSArray arrayWithArray:cardControllers];
}
- (void) reloadDataAnimated:(BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:self.cardReloadHideAnimationDuration
                         animations:^{
            for (KLControllerCard* card in self.controllerCards) {
                [card setState:KLControllerCardStateHiddenBottom animated:NO];
            }
        } completion:^(BOOL finished) {
            [self reloadData];
            [self reloadInputViews];
            for (KLControllerCard* card in self.controllerCards) {
                [card setState:KLControllerCardStateHiddenBottom animated:NO];
            }
            [UIView animateWithDuration:self.cardReloadShowAnimationDuration
                             animations:^{
                for (KLControllerCard* card in self.controllerCards) {
                    [card setState:KLControllerCardStateDefault animated:NO];
                }
            }];
        }];
    }
    else   {
        [self reloadData];
    }
}
- (void) reloadInputViews {
    [super reloadInputViews];
    
    //First remove all of the navigation controllers from the view to avoid redrawing over top of views
    [self removeControllerCardFromSuperView];
    
    //Add the navigation controllers to the view
    for (KLControllerCard* container in self.controllerCards) {
        [self.view addSubview:container];
    }
}

#pragma mark - Manage KLControllerCard helpers

-(void) removeControllerCardFromSuperView {
    for (KLControllerCard* controllerCard in self.controllerCards) {
        [controllerCard.viewController willMoveToParentViewController:nil];  // 1
        [controllerCard removeFromSuperview];            // 2
    }
}


- (NSArray*) controllerCardsAboveCard:(KLControllerCard*) card {
    NSInteger index = [self indexForControllerCard:card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KLControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        
        //Only return cards with an index less than the one being compared to
        return index > currentIndex;
    }]];
}

- (NSArray*) controllerCardsBelowCard:(KLControllerCard*) card {
    NSInteger index = [self indexForControllerCard:card];
    
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KLControllerCard* controllerCard, NSDictionary *bindings) {
        NSInteger currentIndex = [self.controllerCards indexOfObject:controllerCard];
        
        //Only return cards with an index greater than the one being compared to
        return index < currentIndex;
    }]];
}
- (NSArray*) controllerCardsWithoutCard:(KLControllerCard*) card {
    return [self.controllerCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KLControllerCard* controllerCard, NSDictionary *bindings) {        
        //Only return cards that are not equal to the parameter card
        return controllerCard != card;
    }]];
}
#pragma mark - KLNoteViewController Data Source methods

//If the controller is subclassed it will allow these values to be grabbed by the subclass. If not sublclassed it will grab from the assigned datasource.
- (NSInteger)numberOfControllerCardsInNoteView:(KLNoteViewController*) noteView{
    return  [self.dataSource numberOfControllerCardsInNoteView:self];
}

- (UIViewController *)noteView:(KLNoteViewController*)noteView viewControllerAtIndex:(NSInteger) indexPath {
    return [self.dataSource noteView:noteView viewControllerAtIndex:indexPath];
}

#pragma mark - Delegate implementation for KLControllerCard

-(void) controllerCard:(KLControllerCard*)controllerCard didChangeToDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState {

    if (fromState == KLControllerCardStateDefault && toState == KLControllerCardStateFullScreen) {
        //For all cards above the current card move them
        for (KLControllerCard* currentCard  in [self controllerCardsAboveCard:controllerCard]) {
            [currentCard setState: KLControllerCardStateHiddenTop
                         animated: YES];
        }
        for (KLControllerCard* currentCard  in [self controllerCardsBelowCard:controllerCard]) {
            [currentCard setState: KLControllerCardStateHiddenBottom
                         animated: YES];
        }
    }
    else if (fromState == KLControllerCardStateFullScreen && toState == KLControllerCardStateDefault) {
        //For all cards above the current card move them back to default state
        for (KLControllerCard* currentCard  in [self controllerCardsAboveCard:controllerCard]) {
            [currentCard setState: KLControllerCardStateDefault
                         animated: YES];
        }
        //For all cards below the current card move them back to default state
        for (KLControllerCard* currentCard  in [self controllerCardsBelowCard:controllerCard]) {
            [currentCard setState: KLControllerCardStateHiddenBottom
                         animated: NO];
            [currentCard setState: KLControllerCardStateDefault
                         animated: YES];
        }
    }
    else if (fromState == KLControllerCardStateDefault && toState == KLControllerCardStateDefault){
        //If the current state is default and the user does not travel far enough to kick into a new state, then  return all cells back to their default state
        for (KLControllerCard* cardBelow in [self controllerCardsBelowCard: controllerCard]) {
            [cardBelow setState: KLControllerCardStateDefault
                       animated: YES];
        }
    }
    //Notify the delegate of the change
    [self noteViewController: self
     didUpdateControllerCard: controllerCard
              toDisplayState: toState
            fromDisplayState: fromState];
    
}
-(void) noteViewController: (KLNoteViewController*) noteViewController didUpdateControllerCard:(KLControllerCard*)controllerCard toDisplayState:(KLControllerCardState) toState fromDisplayState:(KLControllerCardState) fromState {
    if ([self.delegate respondsToSelector:@selector(noteViewController:didUpdateControllerCard:toDisplayState:fromDisplayState:)])
    {
        [self.delegate noteViewController:self
                  didUpdateControllerCard:controllerCard
                           toDisplayState:toState
                         fromDisplayState:fromState];
    }
}
-(void) controllerCard:(KLControllerCard*)controllerCard didUpdatePanPercentage:(CGFloat) percentage {
    if (controllerCard.state == KLControllerCardStateFullScreen) {
        for (KLControllerCard* currentCard in [self controllerCardsAboveCard: controllerCard]) {
            CGFloat yCoordinate = (CGFloat) currentCard.origin.y * [controllerCard percentageDistanceTravelled];
            [currentCard setYCoordinate: yCoordinate];
        }
    }
    else if (controllerCard.state == KLControllerCardStateDefault) {
        for (KLControllerCard* currentCard in [self controllerCardsBelowCard: controllerCard]) {
            CGFloat deltaDistance = controllerCard.frame.origin.y - controllerCard.origin.y;
            CGFloat yCoordinate = currentCard.origin.y + deltaDistance;
            [currentCard setYCoordinate: yCoordinate];
        }
    }
}
-(void) controllerCard:(KLControllerCard *)controllerCard
willBeginPanningGesture:(UIPanGestureRecognizer*) gesture {
    BOOL gesturesEnabled = NO;
    //Disable touches in other cards
    for (KLControllerCard* currentCard in [self controllerCardsWithoutCard: controllerCard]) {
        [currentCard.panGesture setEnabled: gesturesEnabled];
        [currentCard.tapGesture setEnabled: gesturesEnabled];
    }
}
-(void) controllerCard:(KLControllerCard *)controllerCard
  didEndPanningGesture:(UIPanGestureRecognizer*) gesture {
    BOOL gesturesEnabled = YES;

    //Enable touches in other cards
    for (KLControllerCard* currentCard in [self controllerCardsWithoutCard: controllerCard]) {
        [currentCard.panGesture setEnabled: gesturesEnabled];
        [currentCard.tapGesture setEnabled: gesturesEnabled];
    }
}
@end

@interface KLControllerCard ()
-(void) shrinkCardToScaledSize:(BOOL) animated;
-(void) expandCardToFullSize:(BOOL) animated;
-(void) allowUserInteraction:(BOOL) isAllowed;
@end

@implementation KLControllerCard
-(id) initWithNoteViewController: (KLNoteViewController*) noteViewController
               andViewController: (UIViewController*) viewController {
    if (self = [super initWithFrame: viewController.view.frame]) {
        _noteViewController = noteViewController;
        _viewController = viewController;
        
        originY = [noteViewController defaultVerticalOriginForControllerCard: self];
        
        //Initialize the view's properties
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask: _noteViewController.cardAutoresizingMask];
        
        //Configure navigation controller to have rounded edges while maintaining shadow
        [_viewController.view.layer setCornerRadius: _noteViewController.cardCornerRadius];
        [_viewController.view setClipsToBounds:YES];
        [self addSubview: _viewController.view];
        
        //Configure gesture recognizers
        //Add Pan Gesture
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didPerformPanGesture:)];
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didPerformTapGesture:)];
        [_tapGesture setNumberOfTapsRequired:  _noteViewController.cardMinimumTapsRequired];
        _tapGesture.delegate = self;

        if ([_viewController isKindOfClass:[UINavigationController class]]
                && self.noteViewController.cardPanGestureScope == KLControllerCardPanGestureScopeNavigationBar) {
            [[(UINavigationController*)_viewController navigationBar] addGestureRecognizer: _panGesture];
            
            //Add Tap gesture
            if (self.noteViewController.cardEnablePressGesture) {
                //Add the gesture to the navigation bar
                [[(UINavigationController*)_viewController navigationBar]  addGestureRecognizer: _tapGesture];
            }
        }
        else {
            //Add pan gesture to view
            [_viewController.view addGestureRecognizer: _panGesture];
            //Add Tap gesture
            if (self.noteViewController.cardEnablePressGesture) {
                //Add the gesture to the navigation bar
                [_viewController.view addGestureRecognizer: _tapGesture];
            }
        }

    }
    return self;
}


#pragma mark - UIGestureRecognizer action handlers
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void) didPerformTapGesture:(UITapGestureRecognizer*) recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //Toggle State
        [self toggleStateAnimated:YES];
    }
}

-(void) redrawShadow {
    if (self.noteViewController.cardShadowEnabled) {
        UIBezierPath *path  =  [UIBezierPath bezierPathWithRoundedRect:[self bounds] cornerRadius:self.noteViewController.cardCornerRadius];
        
        [self.layer setShadowOpacity: self.noteViewController.cardShadowOpacity];
        [self.layer setShadowOffset: self.noteViewController.cardShadowOffset];
        [self.layer setShadowRadius: self.noteViewController.cardShadowRadius];
        [self.layer setShadowColor: [self.noteViewController.cardShadowColor CGColor]];
        [self.layer setShadowPath: [path CGPath]];
    }
}

-(void) didPerformPanGesture:(UIPanGestureRecognizer*) recognizer {
    CGPoint location = [recognizer locationInView: self.noteViewController.view];
    CGPoint translation = [recognizer translationInView: self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(controllerCard:willBeginPanningGesture:)]) {
            [self.delegate controllerCard:self
                  willBeginPanningGesture:recognizer];
        }
        //Begin animation
        if (self.state == KLControllerCardStateFullScreen) {
            //Shrink to regular size
            [self shrinkCardToScaledSize:YES];
        }
        //Save the offet to add to the height
        self.panOriginOffset = [recognizer locationInView: self].y;
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        //Check if panning downwards and move other cards
        if (translation.y > 0){
            //Panning downwards from Full screen state
            if (self.state == KLControllerCardStateFullScreen && self.frame.origin.y < originY) {
                //Notify delegate so it can update the coordinates of the other cards unless user has travelled past the origin y coordinate
                if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)]) {
                    [self.delegate controllerCard: self
                           didUpdatePanPercentage: [self percentageDistanceTravelled]];
                }
            }
            //Panning downwards from default state
            else if (self.state == KLControllerCardStateDefault && self.frame.origin.y > originY) {
                //Implements behavior such that when originating at the default position and scrolling down, all other cards below the scrolling card move down at the same rate
                if ([self.delegate respondsToSelector:@selector(controllerCard:didUpdatePanPercentage:)] ) {
                    [self.delegate controllerCard: self
                           didUpdatePanPercentage: [self percentageDistanceTravelled]];
                }
            }
        }
        
        //Track the movement of the users finger during the swipe gesture
        [self setYCoordinate: location.y - self.panOriginOffset];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(controllerCard:didEndPanningGesture:)]) {
            [self.delegate controllerCard:self
                     didEndPanningGesture:recognizer];
        }
        
        //Check if it should return to the origin location
        if ([self shouldReturnToState: self.state fromPoint: [recognizer translationInView:self]]) {
            [self setState: self.state animated:YES];
        }
        else {
            //Toggle state between full screen and default if it doesnt return to the current state
            [self toggleStateAnimated: YES];
        }
    }
}

#pragma mark - Handle resizing of card

-(void) shrinkCardToScaledSize:(BOOL) animated {
    
    //Set the scaling factor if not already set
    if (!scalingFactor) {
        scalingFactor =  [self.noteViewController scalingFactorForIndex: [self.noteViewController indexForControllerCard:self]];
    }
    //If animated then animate the shrinking else no animation
    if (animated) {
        [UIView animateWithDuration:self.noteViewController.cardAnimationDuration
                         animations:^{
                             //Slightly recursive to reduce duplicate code
                             [self shrinkCardToScaledSize:NO];
                         }];
    }
    else {
        [self setTransform: CGAffineTransformMakeScale(scalingFactor, scalingFactor)];
    }
}

-(void) expandCardToFullSize:(BOOL) animated {
    
    //Set the scaling factor if not already set
    if (!scalingFactor) {
        scalingFactor =  [self.noteViewController scalingFactorForIndex: [self.noteViewController indexForControllerCard:self]];
    }
    //If animated then animate the shrinking else no animation
    if (animated) {
        [UIView animateWithDuration:self.noteViewController.cardAnimationDuration
                         animations:^{
                             //Slightly recursive to reduce duplicate code
                             [self expandCardToFullSize:NO];
                         }];
    }
    else {
        [self setTransform: CGAffineTransformMakeScale(self.noteViewController.cardMaximizedScalingFactor, self.noteViewController.cardMaximizedScalingFactor)];
    }
}

#pragma mark - Handle state changes for card

- (void) setState:(KLControllerCardState)state animated:(BOOL) animated{
    
    if (animated) {
        [UIView animateWithDuration: self.noteViewController.cardAnimationDuration
                         animations:^{
            [self setState:state animated:NO];
        } completion:^(BOOL finished) {
            if (state == KLControllerCardStateFullScreen) {
                // Fix scaling bug when expand to full size
                self.frame = self.noteViewController.view.bounds;
                self.viewController.view.frame = self.frame;
                self.viewController.view.layer.cornerRadius = 3.0;
            }
        }];
        return;
    }
    
    // Set corner radius
    [self.viewController.view.layer setCornerRadius: self.noteViewController.cardCornerRadius];
    
    //Full Screen State
    if (state == KLControllerCardStateFullScreen) {
        [self allowUserInteraction: YES];
        [self expandCardToFullSize: animated];
        [self setYCoordinate: 0];
    }
    //Default State
    else if (state == KLControllerCardStateDefault) {
        [self allowUserInteraction: self.noteViewController.allowsInteractionInDefaultState];
        [self shrinkCardToScaledSize: animated];
        [self setYCoordinate: originY];
    }
    //Hidden State - Bottom
    else if (state == KLControllerCardStateHiddenBottom) {
        //Move it off screen and far enough down that the shadow does not appear on screen
        CGFloat offscreenOrigin = self.noteViewController.view.frame.size.height + abs(self.noteViewController.cardShadowOffset.height)*3;
        [self setYCoordinate: offscreenOrigin];
    }
    //Hidden State - Top
    else if (state == KLControllerCardStateHiddenTop) {
        [self setYCoordinate: 0];
    }
    
    //Notify the delegate of the state change (even if state changed to self)
    KLControllerCardState lastState = self.state;
    //Update to the new state
    [self setState:state];
    //Notify the delegate
    if ([self.delegate respondsToSelector:@selector(controllerCard:didChangeToDisplayState:fromDisplayState:)]) {
        [self.delegate controllerCard: self
              didChangeToDisplayState: state
                     fromDisplayState: lastState];
    }
}
-(void) toggleStateAnimated:(BOOL) animated {
    KLControllerCardState nextState = self.state == KLControllerCardStateDefault ? KLControllerCardStateFullScreen : KLControllerCardStateDefault;
    [self setState: nextState
          animated: animated];
}
#pragma mark - Various data helpers 

-(CGPoint) origin {
    return CGPointMake(0, originY);
}

-(CGFloat) percentageDistanceTravelled {
    return self.frame.origin.y/originY;
}

//Boolean for determining if the movement was sufficient to warrent changing states
-(BOOL) shouldReturnToState:(KLControllerCardState) state fromPoint:(CGPoint) point {
    if (state == KLControllerCardStateFullScreen) {
        return ABS(point.y) < kFullScreenDistanceThreshold;
    }
    else if (state == KLControllerCardStateDefault){
        return point.y > - kFullScreenDistanceThreshold;
    }
    return NO;
}

-(void) setYCoordinate:(CGFloat)yValue {
    [self setFrame:CGRectMake(self.frame.origin.x, yValue, self.frame.size.width, self.frame.size.height)];
}
-(void) allowUserInteraction:(BOOL) isAllowed {
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        [[(UINavigationController*)self.viewController topViewController].view setUserInteractionEnabled: isAllowed];
    }
    else {
        [self.viewController.view setUserInteractionEnabled: isAllowed];
    }
}
-(void) setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self redrawShadow];
}
@end
