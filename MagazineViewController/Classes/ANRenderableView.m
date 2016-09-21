//
//  ANRenderableView.m
// Michelin Guide
//
//  Created by Jarosław Pendowski on 24.06.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "ANRenderableView.h"
#import "UIView+Geometry.h"
#import <QuartzCore/QuartzCore.h>

@interface ANRenderableView ()
@property (strong) UIImage *fullRender;
@property (nonatomic) CGImageRef leftHalf;
@property (nonatomic) CGImageRef rightHalf;

@property (nonatomic) BOOL isDirty;

@end

@implementation ANRenderableView

-(id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

-(void)commonInit
{
  self.renderScale = [[UIScreen mainScreen] scale];
  self.isDirty = YES;
}

-(void)renderImageHalfsForFlipping
{
  if (!self.isDirty) {
    return;
  }
  
  CGFloat alpha = self.alpha;
  BOOL hidden = self.hidden;
  
  self.alpha = 1;
  self.hidden = NO;
  
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.renderScale);
  CGContextRef context = UIGraphicsGetCurrentContext();
	// Render the view as image
  [self.layer renderInContext:context];
	// Fetch the image
	UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	// Cleanup
	UIGraphicsEndImageContext();
  
  self.fullRender = renderedImage;
  CGImageRelease(self.leftHalf);
  CGImageRelease(self.rightHalf);
  self.leftHalf = nil;
  self.rightHalf = nil;

  self.alpha = alpha;
  self.hidden = hidden;

  self.isDirty = NO;
}

- (void)setAlpha:(CGFloat)alpha
{
	NSLog(@"%@ alpha: %@", self.backgroundColor, @(alpha));
	[super setAlpha:alpha];

}

- (void)clearImageHalfs
{
  self.fullRender = nil;
  CGImageRelease(self.leftHalf);
  self.leftHalf = nil;
  CGImageRelease(self.rightHalf);
  self.rightHalf = nil;
}

-(void)dealloc
{
  [self clearImageHalfs];
}

-(CGImageRef)leftHalf
{
  if (!_leftHalf && self.fullRender) {
    CGFloat scale = self.renderScale;
    CGImageRef imgref = [self.fullRender CGImage];
    _leftHalf = CGImageCreateWithImageInRect(imgref, CGRectMake(0, 0, self.width / 2 * scale, self.height * scale));
  }
  return _leftHalf;
}

-(CGImageRef)rightHalf
{
  if (!_rightHalf && self.fullRender) {
    CGFloat scale = [self.fullRender scale];
    CGImageRef imgref = [self.fullRender CGImage];
    _rightHalf = CGImageCreateWithImageInRect(imgref, CGRectMake(self.width / 2 * scale, 0, self.width / 2 * scale, self.height * scale));
  }
  return _rightHalf;
}

- (void)setDirty
{
  self.isDirty = YES;
}

@end
