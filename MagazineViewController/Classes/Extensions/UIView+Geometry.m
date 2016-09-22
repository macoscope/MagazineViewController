//
//  UINavigationController+CustomTransitions.m
// Michelin Guide
//
//  Created by jarek on 3/19/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "UIView+Geometry.h"

@implementation UIView (Geometry)

- (CGFloat)mgz_width {
	return CGRectGetWidth(self.frame);
}

- (CGFloat)mgz_height {
	return CGRectGetHeight(self.frame);
}

@end
