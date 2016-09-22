//
//  UINavigationController+CustomTransitions.h
// Michelin Guide
//
//  Created by jarek on 3/19/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

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
