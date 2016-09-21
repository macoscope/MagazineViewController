//
//  UINavigationController+CustomTransitions.h
// Michelin Guide
//
//  Created by jarek on 3/19/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UINavigationControllerCustomAnimationsDelegate <NSObject>

- (void)navigationControllerDidFinishCustomAnimation:(UINavigationController *)navigationController;

@end

@interface UINavigationController (CustomTransitions)
-(void)pushViewControllerWithModalTransition:(UIViewController *)viewController;
-(void)popViewControllerWithModalTransition;
-(void)popToRootViewControllerWithModalTransition;

- (void)setCustomAnimationsDelegate:(id <UINavigationControllerCustomAnimationsDelegate>)delegate;
- (id <UINavigationControllerCustomAnimationsDelegate>)customAnimationsDelegate;


@end
