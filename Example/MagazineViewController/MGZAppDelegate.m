//
//  MGZAppDelegate.m
//  MagazineViewController
//
//  Created by Bartek Chlebek on 09/20/2016.
//  Copyright (c) 2016 Bartek Chlebek. All rights reserved.
//

#import "MGZAppDelegate.h"
@import MagazineViewController;

@interface MGZAppDelegate () <ANPageViewControllerDataSource>
@property (nonatomic, copy) NSArray *viewControllers;
@end

@implementation MGZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.

	[self setupViewControllers];

	ANPageViewController *pageViewController = [ANPageViewController new];
	pageViewController.dataSource = self;

	UIViewController *vc = [UIViewController new];
	vc.view.backgroundColor = [UIColor redColor];

	UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	window.rootViewController = pageViewController;
	[window makeKeyAndVisible];

	self.window = window;

	return YES;
}

- (void)setupViewControllers
{
	self.viewControllers = @[
													 [self newViewControllerWithColor:[UIColor redColor]],
													 [UITableViewController new],
													 [self newImageViewController],
													 ];
}

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

#pragma mark - ANPageViewControllerDataSource

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
