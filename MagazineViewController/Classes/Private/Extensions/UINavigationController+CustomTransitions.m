#import "UINavigationController+CustomTransitions.h"
@import QuartzCore;
@import ObjectiveC;

static char CustomAnimationDelegateKey;


typedef NS_ENUM(ushort, MGZPushDirection) {
  MGZPushDirectionUp,
  MGZPushDirectionDown,
  MGZPushDirectionLeft,
  MGZPushDirectionRight
};

@implementation UINavigationController (CustomTransitions)

- (void)mgz_pushViewControllerWithModalTransition:(UIViewController *)viewController {
  [self mgz_prepareMoveInAnimationForView:self.view.layer withDirection:MGZPushDirectionUp];
  [self pushViewController:viewController animated:NO];
}

- (void)mgz_popViewControllerWithModalTransition {
  NSUInteger index = [self.viewControllers indexOfObject:self.visibleViewController];
  if (index == 0) { return; }
  [self mgz_modalTransitionBetweenCurrentViewControllerAndViewController:self.viewControllers[index - 1]];
}

- (void)mgz_popToRootViewControllerWithModalTransition {
  NSUInteger index = [self.viewControllers indexOfObject:self.visibleViewController];
  if (index == 0) { return; }
  [self mgz_modalTransitionBetweenCurrentViewControllerAndViewController:self.viewControllers[0]];
}

- (void)mgz_modalTransitionBetweenCurrentViewControllerAndViewController:(UIViewController *)controller {
  UIViewController *currentViewController = self.visibleViewController;

  [self.view.window addSubview:currentViewController.view];
  currentViewController.view.frame = CGRectOffset(currentViewController.view.frame,
																									0,
																									CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]));
  [self popViewControllerAnimated:NO];
  [self.view.window bringSubviewToFront:currentViewController.view];

  [UIView animateWithDuration:0.4 animations:^{
    currentViewController.view.transform = CGAffineTransformTranslate(currentViewController.view.transform,
																																			0,
																																			currentViewController.view.bounds.size.height);
  } completion:^(BOOL finished) {
    [currentViewController.view removeFromSuperview];
  }];
}

- (void)mgz_prepareMoveInAnimationForView:(CALayer *)layer withDirection:(MGZPushDirection)direction {
  CATransition *transition = [CATransition animation];
  transition.duration = 0.4f;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionMoveIn;
  transition.delegate = self;
  switch (direction) {
    case MGZPushDirectionDown:
      transition.subtype = kCATransitionFromBottom;
      break;
    case MGZPushDirectionUp:
      transition.subtype = kCATransitionFromTop;
      break;
    case MGZPushDirectionRight:
      transition.subtype = kCATransitionFromRight;
      break;
    default:
      transition.subtype = kCATransitionFromLeft;
      break;
  }
  [layer addAnimation:transition forKey:nil];
}

#pragma mark CATransactionDelegate methods

- (void)mgz_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if (flag) {
    [self.mgz_customAnimationsDelegate navigationControllerDidFinishCustomAnimation:self];
  }
}

#pragma mark Properties

- (NSString *)mgz_customAnimationsDelegate
{
  return objc_getAssociatedObject(self, &CustomAnimationDelegateKey) ;
}

- (void)mgz_setCustomAnimationsDelegate:(id <UINavigationControllerCustomAnimationsDelegate>)delegate
{
  objc_setAssociatedObject(self, &CustomAnimationDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN) ;
}

@end
