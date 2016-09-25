#import "MGZPageViewController.h"
#import "MGZPageViewController+MGZFlipSwipePrivate.h"
#import "UINavigationController+CustomTransitions.h"
#import "MGZPageIndicatorView.h"
#import "UIView+Geometry.h"
#import "UIView+Rendering.h"
@import QuartzCore;

@protocol UINavigationControllerCustomAnimationsDelegate <NSObject>

- (void)navigationControllerDidFinishCustomAnimation:(UINavigationController *)navigationController;

@end

@interface MGZPageViewController () <UINavigationControllerCustomAnimationsDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate>

@property (strong, nonatomic) MGZPageIndicatorView *pageIndicatorView;
@property (strong, nonatomic, readwrite) NSArray *pageViewControllers;
@property (nonatomic, strong) NSTimer *pageIndicatorHidingTimer;

@end

@implementation MGZPageViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationController mgz_setCustomAnimationsDelegate:self];

	CGSize screenSize = [UIScreen mainScreen].applicationFrame.size;
	self.view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);

	UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
																																					action:@selector(panFlipWithGesture:)];
	panGR.minimumNumberOfTouches = 1;
	panGR.maximumNumberOfTouches = 2;

	[self.view addGestureRecognizer:panGR];

	[self reloadPages];
}

- (void)didReceiveMemoryWarning
{
	NSUInteger count = self.pageViewControllers.count;
	NSUInteger currentIndex = self.currentPageIndex % self.pageViewControllers.count;
	NSArray<NSNumber *> *safeIndexes = @[[NSNumber numberWithUnsignedInteger:currentIndex % count],
																			 [NSNumber numberWithUnsignedInteger:(currentIndex -1) % count],
																			 [NSNumber numberWithUnsignedInteger:(currentIndex + 1) % count]];

	for (NSUInteger i = 0; i < self.pageViewControllers.count; i++) {
		if (![safeIndexes containsObject:[NSNumber numberWithUnsignedInteger:i]]) {
			UIViewController * controller = self.pageViewControllers[i];
			[controller.view mgz_clearImageHalfs];
		}
	}
}

- (BOOL)                         gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)reloadCurrentPage
{
	if(!self.isViewLoaded) {
		return;
	}

	NSUInteger currentIndex = MIN(self.currentPageIndex, [self.childViewControllers count] - 1);

	if (currentIndex < [self.pageViewControllers count]) {
		UIViewController *currentDetailController = self.pageViewControllers[currentIndex];
		[currentDetailController.view mgz_renderImageHalfsForFlipping];
	}
}

- (void)reloadPages
{
	if (!self.isViewLoaded) {
		return;
	}

	NSArray *viewControllers = [self.childViewControllers copy];

	for (UIViewController *controller in viewControllers) {
		[controller willMoveToParentViewController:nil];
		[controller.view removeFromSuperview];
		[controller removeFromParentViewController];
		[self removeChildPageViewController:controller];
	}

	for (NSUInteger pageCounter = 0; pageCounter < [self countOfPages]; pageCounter++) {
		[self loadSubControllerForPage:pageCounter];
	}

	if ([self countOfPages] > 0) {
		NSInteger index = self.currentPageIndex < [self countOfPages] ? self.currentPageIndex : 0;
		[self setCurrentPageIndex:index animated:NO direction:MGZViewAnimationDirectionNone];
	}
}

-(MGZThumbnailPageViewController *)currentViewController
{
	if (self.currentPageIndex >= [self.pageViewControllers count]) {
		return nil;
	}
	return self.pageViewControllers[self.currentPageIndex];
}

- (void)loadSubControllerForPage:(NSUInteger)pageCounter
{
	UIViewController *aPageViewController = [self makeViewControllerForPage:pageCounter];

	[self addChildViewController:aPageViewController];
	[self addChildPageViewController:aPageViewController];

	[aPageViewController.view setFrame:self.view.bounds];
	[self.view addSubview:aPageViewController.view];
	[aPageViewController didMoveToParentViewController:self];

	[self configureViewController:aPageViewController forPage:pageCounter];
	
	aPageViewController.view.alpha = 0.0f;

	// force layout of child view controllers in the order they were added
	[aPageViewController.view layoutIfNeeded];
}

- (BOOL)isViewControllerWithIndexVisible:(NSInteger)index
{
	return index == self.currentPageIndex ||
	index == MAX(self.currentPageIndex - 1, 0) ||
	index == MIN(self.currentPageIndex + 1, [self.pageViewControllers count] - 1);
}

- (BOOL)isViewControllerVisible:(UIViewController *)controller
{
	NSInteger *pageIndex = [self.pageViewControllers indexOfObject:controller];
	return [self isViewControllerWithIndexVisible:pageIndex];
}

#pragma mark - Subclasses mocks

- (NSString *)layoutStringForPage:(NSUInteger)pageNumber
{
	assert(NO);
}

- (void)selectionActionForItemAtIndex:(NSUInteger)index
{
	assert(NO);
}

#pragma mark - Accessors

- (void)setCurrentPageIndex:(NSUInteger)newPageIndex
									 animated:(BOOL)animated
									direction:(MGZViewAnimationDirection)direction
{
	if (newPageIndex >= [self.pageViewControllers count]) {
		return;
	}

	NSUInteger currentIndex = MIN(self.currentPageIndex, [self.pageViewControllers count] - 1);

	UIViewController *oldDetailController = self.pageViewControllers[currentIndex];
	UIViewController *newDetailController = self.pageViewControllers[newPageIndex];

	if (animated && currentIndex != newPageIndex) {
		[oldDetailController.view mgz_renderImageHalfsForFlipping];
		[newDetailController.view mgz_renderImageHalfsForFlipping];
	}

	[self willTransitionToViewController:newDetailController];

	[self switchFromViewController:oldDetailController
								toViewController:newDetailController
											 direction:direction
												animated:animated];

	self.currentPageIndex = newPageIndex;

}

#pragma mark - Gesture Page Animation

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
	//	Send a message to the currently active viewController to handle a right swipe
	if ([self countOfPages] == 1) {
		[self showAndHidePageIndicator];
	}
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
	//	Send a message to the currently active viewController to handle a left swipe

	if ([self countOfPages] == 1) {
		[self showAndHidePageIndicator];
	}
}

#pragma mark - PageTransistions

- (NSInteger)nextPageIndexForDirection:(MGZViewAnimationDirection)direction
{
	NSUInteger	viewCount = [self.childViewControllers count];
	return (self.currentPageIndex + direction + viewCount) % viewCount;
}

- (void)transitionInDirection:(MGZViewAnimationDirection)direction
{
	NSUInteger	viewCount = [self.childViewControllers count];
	if (viewCount <= 1) {
		return;
	}

	[self setCurrentPageIndex:[self nextPageIndexForDirection:direction] animated:YES direction:direction];
}


- (void)transitionBackward
{
	[self transitionInDirection:MGZViewAnimationDirectionBackward];
}

- (void)transitionForward
{
	[self transitionInDirection:MGZViewAnimationDirectionForward];
}

- (UIView *)viewToTransitionFromForDirection:(MGZViewAnimationDirection)direction
{
	UIViewController *theController = [self.childViewControllers objectAtIndex:self.currentPageIndex];
	return theController.view;
}

- (UIView *)viewToTransitionToForDirection:(MGZViewAnimationDirection)direction
{
	if ([self.childViewControllers count] <= 1) {
		UIViewController *theController = [self.childViewControllers objectAtIndex:self.currentPageIndex];
		return theController.view;
	}

	NSInteger nextPageIndex = [self nextPageIndexForDirection:direction];
	UIViewController *theController = [self.childViewControllers objectAtIndex:nextPageIndex];
	return theController.view;
}

- (void)willTransitionToViewController:(UIViewController *)viewController
{

}

#pragma mark - Handle the PageView Addition

- (NSUInteger)countOfPages
{
	return [self.dataSource countOfPages];
}

- (UIViewController *)makeViewControllerForPage:(NSUInteger)pageNumber
{
	return [self.dataSource viewControllerForPage:pageNumber];
}

- (void)configureViewController:(UIViewController *)aController forPage:(NSUInteger)pageNumber
{

}

//	Standard swipe transition
- (void)switchFromViewController:(UIViewController *)oldDetailController
								toViewController:(UIViewController *)newDetailController
											 direction:(MGZViewAnimationDirection)direction
												animated:(BOOL)animated
{

	NSTimeInterval animationDuration = (animated ? DEFAULT_VIEW_ANIMATION_DURATION: 0.0f);
	if (oldDetailController == newDetailController) {
		[UIView animateWithDuration:animationDuration animations:^{
			newDetailController.view.transform = CGAffineTransformIdentity;
			newDetailController.view.alpha = 1.0f;
		} completion:^(BOOL finished) {
			[self didTransitionToViewController:newDetailController];
		}];
		return;
	}
	CGFloat offset = (oldDetailController.view.mgz_width * direction);

	newDetailController.view.transform = CGAffineTransformMakeTranslation(offset, 0.0);
	newDetailController.view.alpha = 1.0f;

	[oldDetailController viewWillDisappear:animated];
	[newDetailController viewWillAppear:animated];

	[UIView animateWithDuration:animationDuration animations:^{
		oldDetailController.view.transform = CGAffineTransformMakeTranslation(-offset, 0.0);
		newDetailController.view.transform = CGAffineTransformIdentity;
	} completion:^(BOOL finished) {
		if (finished) {
			[newDetailController viewDidAppear:animated];
			[oldDetailController viewDidDisappear:animated];
		}
	}];
}

- (void)addChildPageViewController:(UIViewController *)controller
{
	NSMutableArray *pages = [self.pageViewControllers mutableCopy];
	if (pages == nil) {
		pages = [NSMutableArray array];
	}

	[pages addObject:controller];
	self.pageViewControllers = pages;
}

- (void)removeChildPageViewController:(UIViewController *)controller
{
	NSMutableArray *pages = [self.pageViewControllers mutableCopy];
	if (pages == nil) {
		return;
	}
	[pages removeObject:controller];
	self.pageViewControllers = pages;
}

#pragma mark - Page Indicator

- (MGZPageIndicatorView *)pageIndicatorView
{
	if (_pageIndicatorView == nil) {
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		_pageIndicatorView = [[bundle loadNibNamed:@"MGZPageIndicatorView" owner:nil options:nil] objectAtIndex:0];
		_pageIndicatorView.frame = CGRectMake(CGRectGetWidth(self.view.frame),
																					roundf(CGRectGetHeight(self.view.frame)/2),
																					CGRectGetWidth(_pageIndicatorView.frame),
																					CGRectGetHeight(_pageIndicatorView.frame));
		[self.view addSubview:_pageIndicatorView];

	}
	return _pageIndicatorView;
}

- (void)setPageIndicatorViewOffScreen:(BOOL)offscreen animated:(BOOL)animated
{
	CGRect newFrame = self.pageIndicatorView.frame;
	newFrame.origin.x = CGRectGetWidth(self.view.bounds) - (offscreen ? 0 : CGRectGetWidth(self.pageIndicatorView.frame));

	void (^animation)() = ^{
		self.pageIndicatorView.frame = newFrame;
	};

	if (animated) {
		[UIView animateWithDuration:0.2
													delay:0.0
												options:UIViewAnimationOptionBeginFromCurrentState
										 animations:animation
										 completion:nil];
	} else {
		animation();
	}

}

- (void)showAndHidePageIndicator
{
	[self showAndHidePageIndicatorWithDelay:[NSNumber numberWithFloat:0.0f]];
}

- (void)showAndHidePageIndicatorWithDelay:(NSNumber *)delayNumber
{
	[self.pageIndicatorHidingTimer invalidate];

	CGFloat delay = [delayNumber floatValue];
	if (![self shouldShowPageIndicator]) {
		return;
	}

	[self.pageIndicatorView setupWithNumberOfPages:[self countOfPages] pageNumber:self.currentPageIndex];
	[self.view bringSubviewToFront:self.pageIndicatorView];

	[UIView animateWithDuration:0.3
												delay:delay
											options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
									 animations:^{
										 [self setPageIndicatorViewOffScreen:NO animated:NO];
									 }
									 completion:^(BOOL finished) {
										 if (finished) {
											 [self.pageIndicatorHidingTimer invalidate];

											 NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
																																				 target:self
																																			 selector:@selector(hidePageIndicator:)
																																			 userInfo:nil
																																				repeats:NO];
											 self.pageIndicatorHidingTimer = timer;
										 }
									 }];
}

- (void)hidePageIndicator:(NSTimer *)timer
{
	[UIView animateWithDuration:0.3f
												delay:0
											options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
									 animations:^{
										 [self setPageIndicatorViewOffScreen:YES animated:NO];
									 }
									 completion:nil];
}

- (void)didTransitionToViewController:(UIViewController *)viewController
{
	[self.pageIndicatorView.layer removeAllAnimations];
	[self setPageIndicatorViewOffScreen:YES animated:NO];

	//to start animation in next loop of NSLoop
	[self performSelector:@selector(showAndHidePageIndicatorWithDelay:)
						 withObject:[NSNumber numberWithFloat:0.25]
						 afterDelay:0.0];

	NSUInteger currentIndex = MIN(self.currentPageIndex, self.pageViewControllers.count - 1);
	NSUInteger prevIndex = (currentIndex - 1) % self.pageViewControllers.count;
	NSUInteger nextIndex = (currentIndex + 1) % self.pageViewControllers.count;

	UIViewController *currentDetailController = self.pageViewControllers[currentIndex];
	UIViewController *prevDetailController = self.pageViewControllers[prevIndex];
	UIViewController *nextDetailController = self.pageViewControllers[nextIndex];

	[currentDetailController.view mgz_renderImageHalfsForFlipping];
	[prevDetailController.view mgz_renderImageHalfsForFlipping];
	[nextDetailController.view mgz_renderImageHalfsForFlipping];
}

- (BOOL)shouldShowPageIndicator
{
	return [self.dataSource shouldDisplayPageIndicator];
}


#pragma mark UINavigationControllerCustomAnimationDelegate

- (void)navigationControllerDidFinishCustomAnimation:(UINavigationController *)navigationController
{
	[self showAndHidePageIndicator];
}

@end
