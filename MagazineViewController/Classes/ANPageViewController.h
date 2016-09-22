//
//  ANPageViewController.h
// Michelin Guide
//
//  Created by Scott Little on 3/2/13.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

@import UIKit;

#define DEFAULT_VIEW_ANIMATION_DURATION 0.35f

typedef NS_ENUM(NSInteger, ANViewAnimationDirection) {
	ANViewAnimationDirectionBackward = -1,
	ANViewAnimationDirectionNone = 0,
	ANViewAnimationDirectionForward = 1
};

@class ANThumbnailPageViewController;

@interface ANPageViewController : UIViewController

@property (atomic, assign) BOOL animating;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL viewsStartWithIdentityTransform;
@property (nonatomic, strong, readonly) NSArray *pageViewControllers;

- (void)setCurrentPageIndex:(NSUInteger)newPageIndex animated:(BOOL)animated direction:(ANViewAnimationDirection)direction;

- (NSUInteger)countOfPages;
- (UIViewController *)makeViewControllerForPage:(NSUInteger)pageNumber;
- (void)configureViewController:(UIViewController *)aController forPage:(NSUInteger)pageNumber;

- (NSInteger)nextPageIndexForDirection:(ANViewAnimationDirection)direction;
- (void)transitionInDirection:(ANViewAnimationDirection)direction;
- (void)transitionBackward;
- (void)transitionForward;
- (UIView *)viewToTransitionFromForDirection:(ANViewAnimationDirection)direction;
- (UIView *)viewToTransitionToForDirection:(ANViewAnimationDirection)direction;

- (BOOL)isViewControllerWithIndexVisible:(NSInteger)index;
- (BOOL)isViewControllerVisible:(UIViewController *)controller;

- (void)willTransitionToViewController:(UIViewController *)viewController;
- (void)didTransitionToViewController:(UIViewController *)viewController;

- (void)switchFromViewController:(UIViewController *)oldDetailController toViewController:(UIViewController *)newDetailController direction:(ANViewAnimationDirection)direction animated:(BOOL)animated;

- (void)reloadPages;
- (void)reloadCurrentPage;
- (ANThumbnailPageViewController *)currentViewController;

- (void)setDataLoaded;
- (void)showAndHidePageIndicator;

@end
