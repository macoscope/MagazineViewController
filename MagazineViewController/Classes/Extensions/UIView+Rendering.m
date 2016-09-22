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

@interface UIView (Rendering)
@property (nonatomic, strong, setter=mgz_setFullRender:) UIImage *mgz_fullRender;
@property (nonatomic, setter=mgz_setLeftHalf:) CGImageRef mgz_leftHalf;
@property (nonatomic, setter=mgz_setRightHalf:) CGImageRef mgz_rightHalf;
@property (nonatomic, setter=mgz_setRenderScale:) CGFloat mgz_renderScale;
@end

@implementation UIView (Rendering)

- (UIImage *)mgz_fullRender
{
  return objc_getAssociatedObject(self, &kFullRenderKey);
}

- (void)mgz_setFullRender:(UIImage *)fullRender
{
  objc_setAssociatedObject(self, &kFullRenderKey, fullRender, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGImageRef)mgz_leftHalf
{
  CGImageRef leftHalf = CFBridgingRetain(objc_getAssociatedObject(self, &kLeftHalfKey));
  if (!leftHalf && self.mgz_fullRender) {
    CGFloat scale = [self.mgz_fullRender scale];
    CGImageRef imgref = [self.mgz_fullRender CGImage];
    CGRect imageRect = CGRectMake(0, 0, self.mgz_width / 2 * scale, self.mgz_height * scale);
    leftHalf = CGImageCreateWithImageInRect(imgref, imageRect);
    self.mgz_leftHalf = leftHalf;
  }
  return leftHalf;
}

- (void)mgz_setLeftHalf:(CGImageRef)leftHalf
{
  if (leftHalf) {
    objc_setAssociatedObject(self, &kLeftHalfKey, CFBridgingRelease(leftHalf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  else {
    objc_setAssociatedObject(self, &kLeftHalfKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

-(CGImageRef)mgz_rightHalf
{
  CGImageRef rightHalf = CFBridgingRetain(objc_getAssociatedObject(self, &kRightHalfKey));
  if (!rightHalf && self.mgz_fullRender) {
    CGFloat scale = [self.mgz_fullRender scale];
    CGImageRef imgref = [self.mgz_fullRender CGImage];
    CGRect imageRect = CGRectMake(self.mgz_width / 2 * scale, 0, self.mgz_width / 2 * scale, self.mgz_height * scale);
    rightHalf = CGImageCreateWithImageInRect(imgref, imageRect);
    self.mgz_rightHalf = rightHalf;
  }
  return rightHalf;
}

- (void)mgz_setRightHalf:(CGImageRef)rightHalf
{
  if (rightHalf) {
    objc_setAssociatedObject(self, &kRightHalfKey, CFBridgingRelease(rightHalf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  else {
    objc_setAssociatedObject(self, &kRightHalfKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

-(void)mgz_renderImageHalfsForFlipping
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

  self.mgz_fullRender = renderedImage;
  self.mgz_leftHalf = nil;
  self.mgz_rightHalf = nil;

  self.alpha = alpha;
  self.hidden = hidden;
}

- (CGFloat)mgz_renderScale
{
  return [UIScreen mainScreen].scale;
}

@end
