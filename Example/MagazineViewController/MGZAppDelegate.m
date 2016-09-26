//
//  MGZAppDelegate.m
//  MagazineViewController
//
//  Created by Bartek Chlebek on 09/20/2016.
//  Copyright (c) 2016 Bartek Chlebek. All rights reserved.
//

#import "MGZAppDelegate.h"
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
											 [self newViewControllerWithColor:[UIColor redColor]],
											 [[UINavigationController alloc] initWithRootViewController:[UITableViewController new]],
											 [self newImageViewController],
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

#pragma mark - Helpers

- (UIViewController *)newViewControllerWithColor:(UIColor *)color
{
	UIViewController *vc = [UIViewController new];
	vc.view.backgroundColor = [UIColor redColor];
	return vc;
}

- (UIViewController *)newImageViewController
{
	UIViewController *vc = [UIViewController new];

	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img"]];
	imageView.frame = vc.view.bounds;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[vc.view addSubview:imageView];

	UIView *orangeView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
	orangeView.backgroundColor = [UIColor orangeColor];
	[vc.view addSubview:orangeView];

	return vc;
}

@end
