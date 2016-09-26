#import "UIViewController+Demo.h"

@implementation UIViewController (Demo)

+ (instancetype)viewControllerWithText:(NSString *)text
{
	UIViewController *viewController = [UIViewController new];

	viewController.view.backgroundColor = [UIColor lightGrayColor];

	UILabel *label = [UILabel new];
	label.frame = viewController.view.bounds;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.text = text;
	label.font = [UIFont boldSystemFontOfSize:48];
	label.textAlignment = NSTextAlignmentCenter;
	[viewController.view addSubview:label];

	return viewController;
}

@end
