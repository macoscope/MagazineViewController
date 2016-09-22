//
//  ANPageViewController+ANFlipSwipePrivate.m
// Michelin Guide
//
//  Created by Scott Little on 21/2/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "ANPageViewController+ANFlipSwipePrivate.h"
@import ObjectiveC;

static char *ANTransitionToInstanceName = "AN_viewToTransitionTo";
static char *ANTransitionFromInstanceName = "AN_viewToTransitionFrom";

static char *ANDirectionInstanceName = "AN_direction";
static char *ANFlipFrontPageInstanceName = "AN_flipFrontPage";
static char *ANPanningInstanceName = "AN_panning";
static char *ANAnimationViewInstanceName = "AN_animationView";
static char *ANLayerFrontInstanceName = "AN_layerFront";
static char *ANLayerFacingInstanceName = "AN_layerFacing";
static char *ANLayerBackInstanceName = "AN_layerBack";
static char *ANLayerRevealInstanceName = "AN_layerReveal";
static char *ANLayerFrontShadowInstanceName = "AN_layerFrontShadow";
static char *ANLayerBackShadowInstanceName = "AN_layerBackShadow";
static char *ANLayerFacingShadowInstanceName = "AN_layerFacingShadow";
static char *ANLayerRevealShadowInstanceName = "AN_layerRevealShadow";

@implementation ANPageViewController (ANFlipSwipePrivate)

#pragma mark - State Accessors

- (ANViewAnimationDirection)direction
{
  id	theObject = objc_getAssociatedObject(self, ANDirectionInstanceName);
  return (ANViewAnimationDirection)[theObject integerValue];
}

- (void)setDirection:(ANViewAnimationDirection)direction
{
  objc_setAssociatedObject(self, ANDirectionInstanceName, [NSNumber numberWithInteger:direction], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)panning
{
  id	theObject = objc_getAssociatedObject(self, ANPanningInstanceName);
  return (BOOL)[theObject boolValue];
}

- (void)setPanning:(BOOL)panning
{
  objc_setAssociatedObject(self, ANPanningInstanceName, [NSNumber numberWithBool:panning], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)flipFrontPage
{
  id	theObject = objc_getAssociatedObject(self, ANFlipFrontPageInstanceName);
  return (BOOL)[theObject boolValue];
}

- (void)setFlipFrontPage:(BOOL)theFlipFrontPage
{
  objc_setAssociatedObject(self, ANFlipFrontPageInstanceName, [NSNumber numberWithBool:theFlipFrontPage], OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - View Accessors

- (UIView *)viewToTransitionTo
{
  id	theView = objc_getAssociatedObject(self, ANTransitionToInstanceName);
  return (UIView *)theView;
}

- (void)setViewToTransitionTo:(UIView *)newView
{
  objc_setAssociatedObject(self, ANTransitionToInstanceName, newView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)viewToTransitionFrom
{
  id	theView = objc_getAssociatedObject(self, ANTransitionFromInstanceName);
  return (UIView *)theView;
}

- (void)setViewToTransitionFrom:(UIView *)newView
{
  objc_setAssociatedObject(self, ANTransitionFromInstanceName, newView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)animationView
{
  id	theView = objc_getAssociatedObject(self, ANAnimationViewInstanceName);
  return (UIView *)theView;
}

- (void)setAnimationView:(UIView *)animationView
{
  objc_setAssociatedObject(self, ANAnimationViewInstanceName, animationView, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Layer Accessors

- (CALayer *)layerFront
{
  id	theObject = objc_getAssociatedObject(self, ANLayerFrontInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFront:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerFrontInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerFacing
{
  id	theObject = objc_getAssociatedObject(self, ANLayerFacingInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFacing:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerFacingInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerBack
{
  id	theObject = objc_getAssociatedObject(self, ANLayerBackInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerBack:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerBackInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerReveal
{
  id	theObject = objc_getAssociatedObject(self, ANLayerRevealInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerReveal:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerRevealInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CAGradientLayer *)layerFrontShadow
{
  id	theObject = objc_getAssociatedObject(self, ANLayerFrontShadowInstanceName);
  return (CAGradientLayer *)theObject;
}

- (void)setLayerFrontShadow:(CAGradientLayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerFrontShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CAGradientLayer *)layerBackShadow
{
  id	theObject = objc_getAssociatedObject(self, ANLayerBackShadowInstanceName);
  return (CAGradientLayer *)theObject;
}

- (void)setLayerBackShadow:(CAGradientLayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerBackShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerFacingShadow
{
  id	theObject = objc_getAssociatedObject(self, ANLayerFacingShadowInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFacingShadow:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerFacingShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerRevealShadow
{
  id	theObject = objc_getAssociatedObject(self, ANLayerRevealShadowInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerRevealShadow:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, ANLayerRevealShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation ANPageFlipHolder

- (id)initWithDirection:(ANViewAnimationDirection)aDirection
{
  self = [super init];

  if (self) {
    self.direction = aDirection;
    self.hasGoneToFlip = NO;
    self.createdAt = [[NSDate date] timeIntervalSinceReferenceDate];
  }
  
  return self;
}

@end
