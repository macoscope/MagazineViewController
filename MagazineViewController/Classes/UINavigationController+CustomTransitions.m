//
//  UINavigationController+CustomTransitions.m
// Michelin Guide
//
//  Created by jarek on 3/19/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "UINavigationController+CustomTransitions.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char CustomAnimationDelegateKey;


typedef NS_ENUM(ushort, ANPushDirection) {
  ANPushDirectionUp,
  ANPushDirectionDown,
  ANPushDirectionLeft,
  ANPushDirectionRight
};

@implementation UINavigationController (CustomTransitions)

-(void)pushViewControllerWithModalTransition:(UIViewController *)viewController {
  [self prepareMoveInAnimationForView:self.view.layer withDirection:ANPushDirectionUp];
	[self pushViewController:viewController animated:NO];
}

-(void)popViewControllerWithModalTransition {
  NSUInteger index = [self.viewControllers indexOfObject:self.visibleViewController];
  if (index == 0) { return; }
  [self modalTransitionBetweenCurrentViewControllerAndViewController:[self.viewControllers objectAtIndex:index - 1]];
}

-(void)popToRootViewControllerWithModalTransition {
  NSUInteger index = [self.viewControllers indexOfObject:self.visibleViewController];
  if (index == 0) { return; }
  [self modalTransitionBetweenCurrentViewControllerAndViewController:[self.viewControllers objectAtIndex:0]];
}

-(void)modalTransitionBetweenCurrentViewControllerAndViewController:(UIViewController *)controller {
  UIViewController *currentViewController = self.visibleViewController;
  
  [self.view.window addSubview:currentViewController.view];
  currentViewController.view.frame = CGRectOffset(currentViewController.view.frame, 0, CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]));
  [self popViewControllerAnimated:NO];
  [self.view.window bringSubviewToFront:currentViewController.view];
  
  [UIView animateWithDuration:0.4 animations:^{
    currentViewController.view.transform = CGAffineTransformTranslate(currentViewController.view.transform, 0, currentViewController.view.bounds.size.height);
  } completion:^(BOOL finished) {
    [currentViewController.view removeFromSuperview];
  }];
}

-(void)prepareMoveInAnimationForView:(CALayer *)layer withDirection:(ANPushDirection)direction {
  CATransition *transition = [CATransition animation];
  transition.duration = 0.4f;
  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  transition.type = kCATransitionMoveIn;
  transition.delegate = self;
  switch (direction) {
    case ANPushDirectionDown:
      transition.subtype = kCATransitionFromBottom;
      break;
    case ANPushDirectionUp:
      transition.subtype = kCATransitionFromTop;
      break;
    case ANPushDirectionRight:
      transition.subtype = kCATransitionFromRight;
      break;
    default:
      transition.subtype = kCATransitionFromLeft;
      break;
  }
	[layer addAnimation:transition forKey:nil];
}

#pragma mark CATransactionDelegate methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if (flag) {
    [self.customAnimationsDelegate navigationControllerDidFinishCustomAnimation:self];
  }
}

#pragma mark Properties

- (NSString *)customAnimationsDelegate
{
  return objc_getAssociatedObject(self, &CustomAnimationDelegateKey) ;
}

- (void)setCustomAnimationsDelegate:(id <UINavigationControllerCustomAnimationsDelegate>)delegate
{
  objc_setAssociatedObject(self, &CustomAnimationDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN) ;
}

@end
