@import UIKit;

@protocol MGZPageViewControllerDataSource <NSObject>
- (NSUInteger)countOfPages;
- (UIViewController *)viewControllerForPage:(NSUInteger)pageNumber;
- (BOOL)shouldDisplayPageIndicator;
@end

#define DEFAULT_VIEW_ANIMATION_DURATION 0.35f

typedef NS_ENUM(NSInteger, MGZViewAnimationDirection) {
  MGZViewAnimationDirectionBackward = -1,
  MGZViewAnimationDirectionNone = 0,
  MGZViewAnimationDirectionForward = 1
};

@class MGZThumbnailPageViewController;

@interface MGZPageViewController : UIViewController
@property (nonatomic, weak) id <MGZPageViewControllerDataSource> dataSource;
@property (atomic, assign) BOOL animating;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) BOOL viewsStartWithIdentityTransform;
@property (nonatomic, strong, readonly) NSArray *pageViewControllers;

- (void)setCurrentPageIndex:(NSUInteger)newPageIndex animated:(BOOL)animated direction:(MGZViewAnimationDirection)direction;

- (void)configureViewController:(UIViewController *)aController forPage:(NSUInteger)pageNumber;

- (NSInteger)nextPageIndexForDirection:(MGZViewAnimationDirection)direction;
- (void)transitionInDirection:(MGZViewAnimationDirection)direction;
- (void)transitionBackward;
- (void)transitionForward;
- (UIView *)viewToTransitionFromForDirection:(MGZViewAnimationDirection)direction;
- (UIView *)viewToTransitionToForDirection:(MGZViewAnimationDirection)direction;

- (BOOL)isViewControllerWithIndexVisible:(NSInteger)index;
- (BOOL)isViewControllerVisible:(UIViewController *)controller;

- (void)willTransitionToViewController:(UIViewController *)viewController;
- (void)didTransitionToViewController:(UIViewController *)viewController;

- (void)switchFromViewController:(UIViewController *)oldDetailController toViewController:(UIViewController *)newDetailController direction:(MGZViewAnimationDirection)direction animated:(BOOL)animated;

- (void)reloadPages;
- (void)reloadCurrentPage;
- (MGZThumbnailPageViewController *)currentViewController;

- (void)showAndHidePageIndicator;

@end
