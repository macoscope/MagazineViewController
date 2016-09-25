@import UIKit;

@protocol UINavigationControllerCustomAnimationsDelegate <NSObject>

- (void)navigationControllerDidFinishCustomAnimation:(UINavigationController *)navigationController;

@end

@interface UINavigationController (CustomTransitions)
- (void)mgz_pushViewControllerWithModalTransition:(UIViewController *)viewController;
- (void)mgz_popViewControllerWithModalTransition;
- (void)mgz_popToRootViewControllerWithModalTransition;

- (void)mgz_setCustomAnimationsDelegate:(id <UINavigationControllerCustomAnimationsDelegate>)delegate;
- (id <UINavigationControllerCustomAnimationsDelegate>)mgz_customAnimationsDelegate;
@end
