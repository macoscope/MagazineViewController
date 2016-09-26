#import "MGZAppDelegate.h"
#import "UIViewController+Demo.h"
@import MagazineViewController;

@interface MGZAppDelegate () <MGZPageViewControllerDataSource>
@property (nonatomic, copy, readonly) NSArray *viewControllers;
@end

@implementation MGZAppDelegate
@synthesize viewControllers = _viewControllers;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[window makeKeyAndVisible];

	self.window = window;

	[self setupPageViewController];

	return YES;
}

- (void)setupPageViewController
{
	MGZPageViewController *pageViewController = [MGZPageViewController new];
	pageViewController.dataSource = self;

	self.window.rootViewController = pageViewController;
}

#pragma mark - Accessors

- (NSArray *)viewControllers
{
	if (_viewControllers) {
		return _viewControllers;
	}

	_viewControllers = @[
											 [UIViewController viewControllerWithText:@"Page 1"],
											 [UIViewController viewControllerWithText:@"Page 2"],
											 [UIViewController viewControllerWithText:@"Page 3"],
											 [UIViewController viewControllerWithText:@"Page 4"],
											 ];

	return _viewControllers;
}

#pragma mark - MGZPageViewControllerDataSource

- (UIViewController *)viewControllerForPage:(NSUInteger)pageNumber
{
	return self.viewControllers[pageNumber];
}

- (NSUInteger)countOfPages
{
	return self.viewControllers.count;
}

- (BOOL)shouldDisplayPageIndicator
{
	return YES;
}

@end
