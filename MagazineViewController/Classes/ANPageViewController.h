//
//  ANPageViewController.h
// Michelin Guide
//
//  Created by Scott Little on 3/2/13.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

@import UIKit;
#import "ANRenderableView.h"
#import "ANViewController.h"

@class ANThumbnailPageViewController;

@interface ANPageViewController : ANViewController

@property (atomic, assign) BOOL animating;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL viewsStartWithIdentityTransform;
@property (nonatomic, strong, readonly) NSArray *pageViewControllers;

- (void)setCurrentPageIndex:(NSUInteger)newPageIndex animated:(BOOL)animated direction:(ANViewAnimationDirection)direction;

- (NSUInteger)countOfPages;
- (ANViewController *)makeViewControllerForPage:(NSUInteger)pageNumber;
- (void)configureViewController:(ANViewController *)aController forPage:(NSUInteger)pageNumber;

- (NSInteger)nextPageIndexForDirection:(ANViewAnimationDirection)direction;
- (void)transitionInDirection:(ANViewAnimationDirection)direction;
- (void)transitionBackward;
- (void)transitionForward;
- (ANRenderableView *)viewToTransitionFromForDirection:(ANViewAnimationDirection)direction;
- (ANRenderableView *)viewToTransitionToForDirection:(ANViewAnimationDirection)direction;

- (BOOL)isViewControllerWithIndexVisible:(NSInteger)index;
- (BOOL)isViewControllerVisible:(ANViewController *)controller;

- (void)willTransitionToViewController:(ANViewController *)viewController;
- (void)didTransitionToViewController:(ANViewController *)viewController;

- (void)switchFromViewController:(ANViewController *)oldDetailController toViewController:(ANViewController *)newDetailController direction:(ANViewAnimationDirection)direction animated:(BOOL)animated;

- (void)reloadPages;
- (void)reloadCurrentPage;
- (ANThumbnailPageViewController *)currentViewController;

- (void)setDataLoaded;
- (void)showAndHidePageIndicator;

@end
