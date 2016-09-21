//
//  MGZViewController.m
//  MagazineViewController
//
//  Created by Bartek Chlebek on 09/20/2016.
//  Copyright (c) 2016 Bartek Chlebek. All rights reserved.
//

#import "MGZViewController.h"

@interface MGZViewController ()

@end

@implementation MGZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
	panRecognizer.minimumNumberOfTouches = 1;
	panRecognizer.maximumNumberOfTouches = 2;
//	[panRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];

	[self.view addGestureRecognizer:panRecognizer];

	// Do any additional setup after loading the view, typically from a nib.
//	self.panning = YES;
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[self transitionForward];
//	});
}

- (NSUInteger)countOfPages
{
	return 3;
}

- (ANViewController *)makeViewControllerForPage:(NSUInteger)pageNumber
{
	ANViewController *vc1 = [ANViewController new];
	switch (pageNumber) {
  case 0:;
			vc1.view.backgroundColor = [UIColor redColor];
			break;
		case 1:;
			vc1.view.backgroundColor = [UIColor blueColor];
			break;
		case 2:;
			vc1.view.backgroundColor = [UIColor greenColor];
			break;
	}
	return vc1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panHandle:(UIPanGestureRecognizer *)gestureRecognizer
{
//	if ([self.childViewControllers count] > 1) {
		[self panFlipWithGesture:gestureRecognizer];
//	}
}

@end
