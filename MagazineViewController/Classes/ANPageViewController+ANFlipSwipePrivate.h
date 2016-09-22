//
//  ANPageViewController+ANFlipSwipePrivate.h
// Michelin Guide
//
//  Created by Scott Little on 21/2/13.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "ANPageViewController.h"
@import QuartzCore;

#define MARGIN	75
#define ANGLE	90

#define SWIPE_LEFT_THRESHOLD -50.0f
#define SWIPE_RIGHT_THRESHOLD 50.0f

static inline double radians (double degrees) {return degrees * M_PI/180;}
static inline double degrees (double radians) {return radians * 180/M_PI;}

@interface ANPageViewController (ANFlipSwipePrivate)

@property (nonatomic, retain) UIView *viewToTransitionFrom;
@property (nonatomic, retain) UIView *viewToTransitionTo;

@property (assign) ANViewAnimationDirection direction;
@property (assign) BOOL panning;
@property (assign) BOOL flipFrontPage;
@property UIView *animationView;
@property CALayer *layerFront;
@property CALayer *layerFacing;
@property CALayer *layerBack;
@property CALayer *layerReveal;
@property CAGradientLayer *layerFrontShadow;
@property CAGradientLayer *layerBackShadow;
@property CALayer *layerFacingShadow;
@property CALayer *layerRevealShadow;

@end

@interface ANPageFlipHolder : NSObject
@property ANViewAnimationDirection direction;
@property BOOL hasGoneToFlip;
@property NSTimeInterval createdAt;
- (id)initWithDirection:(ANViewAnimationDirection)aDirection;
@end

@interface UIView (ANRenderImage)
- (UIImage *)renderImageWithRect:(CGRect)frame;
@end


