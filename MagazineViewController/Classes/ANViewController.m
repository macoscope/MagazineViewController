//
//  ANViewController.m
// Michelin Guide
//
//  Created by Bartosz Ciechanowski on 11/14/12.
//  Copyright (c) 2012 Bartosz Ciechanowski. All rights reserved.
//

#import "ANViewController.h"

@interface ANViewController ()

@end

@implementation ANViewController
@dynamic view;

- (void)loadView
{
	self.view = [ANRenderableView new];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
	if (self.presentedViewController) {
		return [self.presentedViewController shouldAutorotate];
	}
	
	return NO;
}

@end
