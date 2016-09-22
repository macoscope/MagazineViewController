//
//  ANPageViewController+ANFlipSwipe.h
// Michelin Guide
//
//  Created by Scott Little on 6/2/13.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "ANPageViewController.h"

@interface ANPageViewController (ANFlipSwipe)

- (void)performFlipFromView:(UIView *)theFromView
										 toView:(UIView *)theToView
							withDirection:(ANViewAnimationDirection)aDirection;
- (void)panFlipWithGesture:(UIPanGestureRecognizer *)gestureRecognizer;

@end
