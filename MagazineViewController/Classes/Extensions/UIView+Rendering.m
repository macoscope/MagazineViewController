//
//  UIView.m
// Michelin Guide
//
//  Created by Jarosław Pendowski on 24.06.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "UIView+Geometry.h"
@import QuartzCore;
@import ObjectiveC;

static char kLeftHalfKey;
static char kRightHalfKey;
static char kFullRenderKey;

@implementation UIView (Rendering)

- (UIImage *)fullRender
{
	return objc_getAssociatedObject(self, &kFullRenderKey);
}

- (void)setFullRender:(UIImage *)fullRender
{
	objc_setAssociatedObject(self, &kFullRenderKey, fullRender, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGImageRef)leftHalf
{
	CGImageRef leftHalf = CFBridgingRetain(objc_getAssociatedObject(self, &kLeftHalfKey));
	if (!leftHalf && self.fullRender) {
		CGFloat scale = [self.fullRender scale];
		CGImageRef imgref = [self.fullRender CGImage];
		leftHalf = CGImageCreateWithImageInRect(imgref, CGRectMake(0, 0, self.width / 2 * scale, self.height * scale));
		self.leftHalf = leftHalf;
	}
	return leftHalf;
}

- (void)setLeftHalf:(CGImageRef)leftHalf
{
	if (leftHalf) {
		objc_setAssociatedObject(self, &kLeftHalfKey, CFBridgingRelease(leftHalf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	else {
		objc_setAssociatedObject(self, &kLeftHalfKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

-(CGImageRef)rightHalf
{
	CGImageRef rightHalf = CFBridgingRetain(objc_getAssociatedObject(self, &kRightHalfKey));
	if (!rightHalf && self.fullRender) {
		CGFloat scale = [self.fullRender scale];
		CGImageRef imgref = [self.fullRender CGImage];
		rightHalf = CGImageCreateWithImageInRect(imgref, CGRectMake(self.width / 2 * scale, 0, self.width / 2 * scale, self.height * scale));
		self.rightHalf = rightHalf;
	}
	return rightHalf;
}

- (void)setRightHalf:(CGImageRef)rightHalf
{
	if (rightHalf) {
		objc_setAssociatedObject(self, &kRightHalfKey, CFBridgingRelease(rightHalf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	else {
		objc_setAssociatedObject(self, &kRightHalfKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

-(void)renderImageHalfsForFlipping
{
  CGFloat alpha = self.alpha;
  BOOL hidden = self.hidden;
  
  self.alpha = 1;
  self.hidden = NO;

  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
	// Render the view as image
  [self.layer renderInContext:context];
	// Fetch the image
	UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	// Cleanup
	UIGraphicsEndImageContext();
  
  self.fullRender = renderedImage;
  self.leftHalf = nil;
  self.rightHalf = nil;

  self.alpha = alpha;
  self.hidden = hidden;
}

- (CGFloat)renderScale
{
	return [UIScreen mainScreen].scale;
}

@end
