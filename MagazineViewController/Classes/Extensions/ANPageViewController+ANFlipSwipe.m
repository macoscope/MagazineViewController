//
//  ANPageViewController+ANFlipSwipe.m
// Michelin Guide
//
//  Created by Scott Little on 6/2/13.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "ANPageViewController+ANFlipSwipe.h"
#import "ANPageViewController+ANFlipSwipePrivate.h"
#import "UIView+Rendering.h"

static NSMutableArray *pendingFlips;
static dispatch_queue_t pageFlipDelayQueue;

static inline CGSize CGImageGetSize(CGImageRef imgRef, CGFloat scale)
{
  return CGSizeMake(CGImageGetWidth(imgRef) / scale, CGImageGetHeight(imgRef) / scale);
}

@implementation ANPageViewController (ANFlipSwipe)

#pragma mark - Action Methods


- (void)panFlipWithGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    pendingFlips = [NSMutableArray array];
    pageFlipDelayQueue = dispatch_queue_create("com.macoscope.annkh.pageFlipQueue", NULL);
  });

  UIGestureRecognizerState state = [gestureRecognizer state];
  CGPoint currentPosition = [gestureRecognizer locationInView:self.view];
  CGPoint translation = [gestureRecognizer translationInView:self.view];

  if (!self.panning && !self.animating && state == UIGestureRecognizerStateChanged && ABS(translation.x) > 5) {
    ANViewAnimationDirection direction = ANViewAnimationDirectionNone;
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    if (velocity.x < 0.0f) {
      direction = ANViewAnimationDirectionForward;
    }
    else if (velocity.x > 0.0f) {
      direction = ANViewAnimationDirectionBackward;
    }

    if (self.animating) {
      dispatch_sync(pageFlipDelayQueue, ^{
        [self removeOldPendingFlips];
        //	Always adds a new held flip to the list
        ANPageFlipHolder *flipHolder = [[ANPageFlipHolder alloc] initWithDirection:direction];
        [pendingFlips addObject:flipHolder];
      });
      return;
    }

    self.animating = YES;
    self.panning = YES;

    translation = CGPointZero;
    [gestureRecognizer setTranslation:translation inView:self.view];

    self.viewToTransitionFrom = [self viewToTransitionFromForDirection:direction];
    self.viewToTransitionTo = [self viewToTransitionToForDirection:direction];

    [self.viewToTransitionFrom mgz_renderImageHalfsForFlipping];
    [self.viewToTransitionTo mgz_renderImageHalfsForFlipping];

    self.direction = direction;

    [self startFlipWithDirection:direction];
  }

  if (self.panning && state == UIGestureRecognizerStateChanged)
  {
    CGFloat progress = [self progressFromPosition:currentPosition withTranslation:translation];
    BOOL wasFlipFrontPage = self.flipFrontPage;
    self.flipFrontPage = (progress < 1);

    if (wasFlipFrontPage != self.flipFrontPage) {
      // switching between the 2 halves of the animation - between front and back sides of the page we're turning
      [self switchToStage:(self.flipFrontPage? 0 : 1)];
    }
    if (self.flipFrontPage) {
      [self doFlip1:progress];
    }
    else {
      [self doFlip2:progress - 1];
    }
  }

  if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
  {
    if (self.panning)
    {
      // If moving slowly, let page fall either forward or back depending on where we were
      BOOL shouldFallBack = [self progressFromPosition:currentPosition withTranslation:translation] < 1.0;

      CGFloat velocity = [gestureRecognizer velocityInView:self.view].x;

      const CGFloat kMinimumForceFlipVelocity = 100.0;

      if (velocity < -kMinimumForceFlipVelocity) {
        // Detected a swipe to the left
        shouldFallBack = self.direction == ANViewAnimationDirectionBackward;
      }
      else if (velocity > kMinimumForceFlipVelocity) {
        // Detected a swipe to the right
        shouldFallBack = self.direction == ANViewAnimationDirectionForward;
      }

      const CGFloat kMaxVel = 3000.0;
      const CGFloat kMaxDuration = DEFAULT_VIEW_ANIMATION_DURATION;
      const CGFloat kMinDuration = kMaxDuration/3.0;

      NSTimeInterval duration = MAX(kMinDuration, kMinDuration + (kMaxDuration - kMinDuration)*(1.0 - fabs(velocity)/kMaxVel)) ;

      // finishAnimation
      if (shouldFallBack != self.flipFrontPage) {
        // 2-stage animation (we're swiping either forward or back)
        CGFloat progress = [self progressFromPosition:currentPosition withTranslation:translation];
        if ((self.flipFrontPage && progress > 1) || (!self.flipFrontPage && progress < 1))
          progress = 1;
        if (progress > 1)
          progress -= 1;
        [self animateFlip1:shouldFallBack fromProgress:progress duration:duration];
      }
      else {
        // 1-stage animation
        CGFloat fromProgress = [self progressFromPosition:currentPosition withTranslation:translation];
        if (!shouldFallBack)
          fromProgress -= 1;
        [self animateFlip2:shouldFallBack fromProgress:fromProgress duration:duration];
      }
      self.panning = NO;
    }
  }
}


- (void)performFlipFromView:(UIView *)theFromView toView:(UIView *)theToView withDirection:(ANViewAnimationDirection)aDirection
{
  self.animating = YES;
  self.viewToTransitionFrom = theFromView;
  self.viewToTransitionTo = theToView;

  [self startFlipWithDirection:aDirection];
  [self animateFlip1:NO fromProgress:0 duration:DEFAULT_VIEW_ANIMATION_DURATION];
}

#pragma mark - Layer Construction

- (void)updateLayerImagesForDirection:(ANViewAnimationDirection)aDirection
{

  BOOL forwards = aDirection == ANViewAnimationDirectionForward;

  CGRect bounds = self.viewToTransitionFrom.bounds;
  CGFloat scale = self.viewToTransitionFrom.mgz_renderScale;

  CGRect upperRect = bounds;
  upperRect.size.width = bounds.size.width / 2;
  CGRect lowerRect = upperRect;
  lowerRect.origin.x += upperRect.size.width;

  CGFloat width = bounds.size.height;
  CGFloat height = bounds.size.width/2;
  CGFloat upperHeight = roundf(height * scale) / scale; // round heights to integer for odd height
  CGPoint layerPosition = CGPointMake(upperHeight, width/2);

  // front Page  = the half of current view we are flipping during 1st half
  // facing Page = the other half of the current view (doesn't move, gets covered by back page during 2nd half)
  // back Page   = the half of the next view that appears on the flipping page during 2nd half
  // reveal Page = the other half of the next view (doesn't move, gets revealed by front page during 1st half)
  CGImageRef pageFrontImage = (forwards
                               ? self.viewToTransitionFrom.mgz_rightHalf
                               : self.viewToTransitionFrom.mgz_leftHalf);
  CGImageRef pageFacingImage = (forwards
                                ? self.viewToTransitionFrom.mgz_leftHalf
                                : self.viewToTransitionFrom.mgz_rightHalf);

  self.viewToTransitionTo.alpha = 1.0f;

  CGImageRef pageBackImage = forwards ? self.viewToTransitionTo.mgz_leftHalf : self.viewToTransitionTo.mgz_rightHalf;
  CGImageRef pageRevealImage = forwards ? self.viewToTransitionTo.mgz_rightHalf : self.viewToTransitionTo.mgz_leftHalf;

  self.layerReveal.frame = (CGRect){CGPointZero, CGImageGetSize(pageRevealImage, scale) };
  self.layerReveal.position = layerPosition;
  [self.layerReveal setContents:(__bridge id)pageRevealImage];
  self.layerFront.frame = (CGRect){CGPointZero, CGImageGetSize(pageFrontImage, scale) };
  self.layerFront.position = layerPosition;
  [self.layerFront setContents:(__bridge id)pageFrontImage];
  self.layerFacing.frame = (CGRect){CGPointZero, CGImageGetSize(pageFacingImage, scale) };
  self.layerFacing.position = layerPosition;
  [self.layerFacing setContents:(__bridge id)pageFacingImage];
  self.layerBack.frame = (CGRect){CGPointZero, CGImageGetSize(pageBackImage, scale) };
  self.layerBack.position = layerPosition;
  [self.layerBack setContents:(__bridge id)pageBackImage];
}

- (void)buildLayers:(ANViewAnimationDirection)aDirection
{
  UIView *containerView = [self.viewToTransitionFrom superview];

  // view to hold all our sublayers
  self.animationView = [[UIView alloc] initWithFrame:self.viewToTransitionFrom.frame];
  self.animationView.backgroundColor = [UIColor clearColor];
  [containerView insertSubview:self.animationView aboveSubview:self.viewToTransitionTo];
  [containerView bringSubviewToFront:self.animationView];

  BOOL forwards = aDirection == ANViewAnimationDirectionForward;
  self.layerReveal = [CALayer layer];
  self.layerReveal.anchorPoint = CGPointMake(forwards? 0 : 1, 0.5);
  [self.animationView.layer addSublayer:self.layerReveal];

  self.layerFront = [CALayer layer];
  self.layerFront.anchorPoint = CGPointMake(forwards? 0 : 1, 0.5);
  [self.animationView.layer addSublayer:self.layerFront];

  self.layerFacing = [CALayer layer];
  self.layerFacing.anchorPoint = CGPointMake(forwards? 1 : 0, 0.5);
  [self.animationView.layer addSublayer:self.layerFacing];

  self.layerBack = [CALayer layer];
  self.layerBack.anchorPoint = CGPointMake(forwards? 1 : 0, 0.5);

  [self updateLayerImagesForDirection:aDirection];

  //	Ensure that the order of the From and To views in the view hierarchy is correct.
  //	BTW, it is done here to ensure that the AnimationView has the proper content to hide this switch.
  NSUInteger fromIndex = [containerView.subviews indexOfObject:self.viewToTransitionFrom];
  NSUInteger toIndex = [containerView.subviews indexOfObject:self.viewToTransitionTo];
  if (fromIndex > toIndex) {
    [containerView exchangeSubviewAtIndex:fromIndex withSubviewAtIndex:toIndex];
  }

  // Create shadow layers
  self.layerFrontShadow = [CAGradientLayer layer];
  [self.layerFront addSublayer:self.layerFrontShadow];
  self.layerFrontShadow.frame = self.layerFront.bounds;
  self.layerFrontShadow.opacity = 0.0;
  if (forwards)
    self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
  else
    self.layerFrontShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[UIColor blackColor].CGColor, (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], nil];
  self.layerFrontShadow.startPoint = CGPointMake(forwards? 0 : 0.5, 0.5);
  self.layerFrontShadow.endPoint = CGPointMake(forwards? 0.5 : 1, 0.5);
  self.layerFrontShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.1 : 0.9], [NSNumber numberWithDouble:1], nil];

  self.layerBackShadow = [CAGradientLayer layer];
  [self.layerBack addSublayer:self.layerBackShadow];
  self.layerBackShadow.frame = self.layerBack.bounds;
  self.layerBackShadow.opacity = 0.1;
  if (forwards)
    self.layerBackShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[UIColor blackColor].CGColor, (id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], nil];
  else
    self.layerBackShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor], (id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil];
  self.layerBackShadow.startPoint = CGPointMake(forwards? 0.5 : 0, 0.5);
  self.layerBackShadow.endPoint = CGPointMake(forwards? 1 : 0.5, 0.5);
  self.layerBackShadow.locations = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0], [NSNumber numberWithDouble:forwards? 0.9 : 0.1], [NSNumber numberWithDouble:1], nil];

  self.layerRevealShadow = [CALayer layer];
  [self.layerReveal addSublayer:self.layerRevealShadow];
  self.layerRevealShadow.frame = self.layerReveal.bounds;
  self.layerRevealShadow.backgroundColor = [UIColor blackColor].CGColor;
  self.layerRevealShadow.opacity = 0.5;

  self.layerFacingShadow = [CALayer layer];
  self.layerFacingShadow.frame = self.layerFacing.bounds;
  self.layerFacingShadow.backgroundColor = [UIColor blackColor].CGColor;
  self.layerFacingShadow.opacity = 0.0;

  // Perspective is best proportional to the height of the pieces being folded away, rather than a fixed value
  // the larger the piece being folded, the more perspective distance (zDistance) is needed.
  // m34 = -1/zDistance
  CATransform3D transform = CATransform3DIdentity;
  CGFloat height = self.viewToTransitionFrom.bounds.size.width/2;
  transform.m34 = - 1 / (height * 4.666667);
  self.animationView.layer.sublayerTransform = transform;

  // set shadows on the 2 pages we'll be animating
  //self.layerFront.shadowOpacity = 0.25;
  self.layerFront.shadowOffset = CGSizeMake(0,3);
  [self.layerFront setShadowPath:[[UIBezierPath bezierPathWithRect:[self.layerFront bounds]] CGPath]];
  self.layerBack.shadowOpacity = 0.25;
  self.layerBack.shadowOffset = CGSizeMake(0,3);
  [self.layerBack setShadowPath:[[UIBezierPath bezierPathWithRect:[self.layerBack bounds]] CGPath]];
}



#pragma mark - Utilities Methods

- (CGFloat)progressFromPosition:(CGPoint)position withTranslation:(CGPoint)transition
{
  // Determine where we are in our page turn animation
  // 0 - 1 means flipping the front-side of the page
  // 1 - 2 means flipping the back-side of the page
  BOOL isForward = (self.direction == ANViewAnimationDirectionForward);

  CGFloat halfWidth = self.view.frame.size.width / 2;
  CGFloat progress = transition.x / halfWidth * (isForward? -1 : 1);
  if (progress < 0)
    progress = 0;
  if (progress > 2)
    progress = 2;
  return progress;
}

// switching between the 2 halves of the animation - between front and back sides of the page we're turning
- (void)switchToStage:(int)stageIndex
{
  // 0 = stage 1, 1 = stage 2
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

  if (stageIndex == 0)
  {
    [self doFlip2:0];
    [self.animationView.layer insertSublayer:self.layerFacing above:self.layerReveal];
    [self.animationView.layer insertSublayer:self.layerFront below:self.layerFacing];
    [self.layerReveal addSublayer:self.layerRevealShadow];
    [self.layerBack removeFromSuperlayer];
    [self.layerFacingShadow removeFromSuperlayer];
  }
  else
  {
    [self doFlip1:1];
    [self.animationView.layer insertSublayer:self.layerReveal above:self.layerFacing];
    [self.animationView.layer insertSublayer:self.layerBack below:self.layerReveal];
    [self.layerFacing addSublayer:self.layerFacingShadow];
    [self.layerFront removeFromSuperlayer];
    [self.layerRevealShadow removeFromSuperlayer];
  }

  [CATransaction commit];
}


#pragma mark - Flipping!

- (void)startFlipWithDirection:(ANViewAnimationDirection)aDirection
{
  self.direction = aDirection;
  self.flipFrontPage = YES;
  [self buildLayers:aDirection];

  // set the back page in the vertical position (midpoint of animation)
  [self doFlip2:0];
}


- (void)removeOldPendingFlips
{
  NSMutableArray *removeFlips = [NSMutableArray array];
  for (ANPageFlipHolder *aHolder in pendingFlips) {
    NSTimeInterval timeDiff = ([[NSDate date] timeIntervalSinceReferenceDate] - aHolder.createdAt);
    //	If it should flip or is older than 2 seconds we dispose of it
    if (timeDiff > 1.0f) {
      //	Remove the holder
      [removeFlips addObject:aHolder];
    }
  }
  [pendingFlips removeObjectsInArray:removeFlips];
}

- (void)animateFlip1:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress duration:(NSTimeInterval)totalDuration
{
  // 2-stage animation
  CALayer *layer = shouldFallBack? self.layerBack : self.layerFront;
  CALayer *flippingShadow = shouldFallBack? self.layerBackShadow : self.layerFrontShadow;
  CALayer *coveredShadow = shouldFallBack? self.layerFacingShadow : self.layerRevealShadow;

  if (shouldFallBack) {
    fromProgress = 1 - fromProgress;
  }
  CGFloat toProgress = 1;

  // Figure out how many frames we want
  CGFloat duration = totalDuration * (toProgress - fromProgress);
  NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS

  // Create a transaction
  [CATransaction begin];
  [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
  [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn] forKey:kCATransactionAnimationTimingFunction];
  [CATransaction setCompletionBlock:^{
    // 2nd half of animation, once 1st half completes
    self.flipFrontPage = shouldFallBack;
    [self switchToStage:shouldFallBack? 0 : 1];
    [self animateFlip2:shouldFallBack fromProgress:shouldFallBack? 1 : 0 duration:totalDuration];
  }];

  // Create the animation
  BOOL forwards = [self direction] == ANViewAnimationDirectionForward;
  NSString *rotationKey = @"transform.rotation.y";
  double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * M_PI / 180;

  // Flip front page from flat up to vertical
  CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:rotationKey];
  [animation setFromValue:[NSNumber numberWithDouble:90 * factor * fromProgress]];
  [animation setToValue:[NSNumber numberWithDouble:90*factor]];
  [layer addAnimation:animation forKey:nil];
  [layer setTransform:CATransform3DMakeRotation(90*factor, 0, 1, 0)];

  // Shadows

  // darken front page just slightly as we flip (just to give it a crease where it touches facing page)
  animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  [animation setFromValue:[NSNumber numberWithDouble:0.1 * fromProgress]];
  [animation setToValue:[NSNumber numberWithDouble:0.1]];
  [flippingShadow addAnimation:animation forKey:nil];
  [flippingShadow setOpacity:0.1];

  // lighten the page that is revealed by front page flipping up (along a cosine curve)
  NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
  CGFloat progress;
  CGFloat cosOpacity;
  for (int frame = 0; frame <= frameCount; frame++)
  {
    progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
    //progress = (((float)frame) / frameCount);
    cosOpacity = cos(radians(90 * progress)) * (1./3);
    if (frame == frameCount)
      cosOpacity = 0;
    [arrayOpacity addObject:[NSNumber numberWithFloat:cosOpacity]];
  }

  CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  [keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
  [coveredShadow addAnimation:keyAnimation forKey:nil];
  [coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];

  // shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
  arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
  CGFloat shadowProgress;
  for (int frame = 0; frame <= frameCount; frame++)
  {
    progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
    shadowProgress = progress * 8;
    if (shadowProgress > 1)
      shadowProgress = 1;

    [arrayOpacity addObject:[NSNumber numberWithFloat:0.25 * shadowProgress]];
  }

  keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
  [keyAnimation setCalculationMode:kCAAnimationLinear];
  [keyAnimation setValues:arrayOpacity];
  [layer addAnimation:keyAnimation forKey:nil];
  [layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];

  // Commit the transaction for 1st half
  [CATransaction commit];
}

- (void)animateFlip2:(BOOL)shouldFallBack fromProgress:(CGFloat)fromProgress duration:(NSTimeInterval)totalDuration
{
  // 1-stage animation
  CALayer *layer = shouldFallBack? self.layerFront : self.layerBack;
  CALayer *flippingShadow = shouldFallBack? self.layerFrontShadow : self.layerBackShadow;
  CALayer *coveredShadow = shouldFallBack? self.layerRevealShadow : self.layerFacingShadow;

  // Figure out how many frames we want
  CGFloat duration = totalDuration;
  NSUInteger frameCount = ceilf(duration * 60); // we want 60 FPS

  // Build an array of keyframes (each a single transform)
  if (shouldFallBack)
    fromProgress = 1 - fromProgress;
  CGFloat toProgress = 1;

  // Create a transaction
  [CATransaction begin];
  [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
  [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] forKey:kCATransactionAnimationTimingFunction];
  [CATransaction setCompletionBlock:^{
    // once 2nd half completes
    [self endFlip:!shouldFallBack];

    // Clear flags
    [self setAnimating:NO];
    [self setPanning:NO];
  }];

  // Create the animation
  BOOL forwards = [self direction] == ANViewAnimationDirectionForward;
  NSString *rotationKey = @"transform.rotation.y";
  double factor = (shouldFallBack? -1 : 1) * (forwards? -1 : 1) * M_PI / 180;

  // Flip back page from vertical down to flat
  CABasicAnimation* animation2 = [CABasicAnimation animationWithKeyPath:rotationKey];
  [animation2 setFromValue:[NSNumber numberWithDouble:-90*factor*(1-fromProgress)]];
  [animation2 setToValue:[NSNumber numberWithDouble:0]];
  [animation2 setFillMode:kCAFillModeForwards];
  [animation2 setRemovedOnCompletion:NO];
  [layer addAnimation:animation2 forKey:nil];
  [layer setTransform:CATransform3DIdentity];

  // Shadows

  // Lighten back page just slightly as we flip (just to give it a crease where it touches reveal page)
  animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
  [animation2 setFromValue:[NSNumber numberWithDouble:0.1 * (1-fromProgress)]];
  [animation2 setToValue:[NSNumber numberWithDouble:0]];
  [animation2 setFillMode:kCAFillModeForwards];
  [animation2 setRemovedOnCompletion:NO];
  [flippingShadow addAnimation:animation2 forKey:nil];
  [flippingShadow setOpacity:0];

  // Darken facing page as it gets covered by back page flipping down (along a sine curve)
  NSMutableArray* arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
  CGFloat progress;
  CGFloat sinOpacity;
  for (int frame = 0; frame <= frameCount; frame++)
  {
    progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
    sinOpacity = (sin(radians(90 * progress))* (1./3));
    if (frame == 0)
      sinOpacity = 0;
    [arrayOpacity addObject:[NSNumber numberWithFloat:sinOpacity]];
  }

  CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  [keyAnimation setValues:[NSArray arrayWithArray:arrayOpacity]];
  [coveredShadow addAnimation:keyAnimation forKey:nil];
  [coveredShadow setOpacity:[[arrayOpacity lastObject] floatValue]];

  // shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
  arrayOpacity = [NSMutableArray arrayWithCapacity:frameCount + 1];
  CGFloat shadowProgress;
  for (int frame = 0; frame <= frameCount; frame++)
  {
    progress = fromProgress + (toProgress - fromProgress) * ((float)frame) / frameCount;
    shadowProgress = (1 - progress) * 8;
    if (shadowProgress > 1)
      shadowProgress = 1;

    [arrayOpacity addObject:[NSNumber numberWithFloat:0.25 * shadowProgress]];
  }

  keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowOpacity"];
  [keyAnimation setCalculationMode:kCAAnimationLinear];
  [keyAnimation setValues:arrayOpacity];
  [layer addAnimation:keyAnimation forKey:nil];
  [layer setShadowOpacity:[[arrayOpacity lastObject] floatValue]];

  // Commit the transaction
  [CATransaction commit];
}

- (void)doFlip1:(CGFloat)progress
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

  if (progress < 0)
    progress = 0;
  else if (progress > 1)
    progress = 1;

  [self.layerFront setTransform:[self flipTransform1:progress]];
  [self.layerFrontShadow setOpacity:0.1 * progress];
  CGFloat cosOpacity = cos(radians(90 * progress)) * (1./3);
  [self.layerRevealShadow setOpacity:cosOpacity];

  // shadow opacity should fade up from 0 to 0.5 at 12.5% progress then remain there through 100%
  CGFloat shadowProgress = progress * 8;
  if (shadowProgress > 1)
    shadowProgress = 1;
  [self.layerFront setShadowOpacity:0.25 * shadowProgress];

  [CATransaction commit];
}

- (void)doFlip2:(CGFloat)progress
{
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

  if (progress < 0)
    progress = 0;
  else if (progress > 1)
    progress = 1;

  [self.layerBack setTransform:[self flipTransform2:progress]];
  [self.layerBackShadow setOpacity:0.1 * (1- progress)];
  CGFloat sinOpacity = sin(radians(90 * progress)) * (1./3);
  [self.layerFacingShadow setOpacity:sinOpacity];

  // shadow opacity on flipping page should be 0.5 through 87.5% progress then fade to 0 at 100%
  CGFloat shadowProgress = (1 - progress) * 8;
  if (shadowProgress > 1)
    shadowProgress = 1;
  [self.layerBack setShadowOpacity:0.25 * shadowProgress];

  [CATransaction commit];
}

- (CATransform3D)flipTransform1:(CGFloat)progress
{
  CATransform3D tHalf1 = CATransform3DIdentity;

  // rotate away from viewer
  BOOL isForward = (self.direction == ANViewAnimationDirectionForward);
  tHalf1 = CATransform3DRotate(tHalf1, radians(ANGLE * progress * (isForward? -1 : 1)), 0, 1, 0);

  return tHalf1;
}

- (CATransform3D)flipTransform2:(CGFloat)progress
{
  CATransform3D tHalf2 = CATransform3DIdentity;

  // rotate away from viewer
  BOOL isForward = (self.direction == ANViewAnimationDirectionForward);
  tHalf2 = CATransform3DRotate(tHalf2, radians(ANGLE * (1 - progress)) * (isForward? 1 : -1), 0, 1, 0);

  return tHalf2;
}

- (void)endFlip:(BOOL)completed
{

  self.viewToTransitionTo.alpha = (completed?1.0f:0.0f);
  self.viewToTransitionFrom.alpha = (completed?0.0f:1.0f);

  // cleanup
  [self.animationView removeFromSuperview];
  self.animationView = nil;
  self.layerFront = nil;
  self.layerBack = nil;
  self.layerFacing = nil;
  self.layerReveal = nil;
  self.layerFrontShadow = nil;
  self.layerBackShadow = nil;
  self.layerFacingShadow = nil;
  self.layerRevealShadow = nil;

  self.viewToTransitionTo = nil;
  self.viewToTransitionFrom = nil;
  
  if (completed) {
    [self setCurrentPageIndex:[self nextPageIndexForDirection:self.direction]];
    [self didTransitionToViewController:self.currentViewController];
  }
  
  self.panning = NO;
  self.animating = NO;
  
  dispatch_sync(pageFlipDelayQueue, ^{
    [self removeOldPendingFlips];
    //	Go ahead and process the call and remove this pending flip
    if (pendingFlips.count > 0) {
      ANPageFlipHolder *flipHolder = [pendingFlips objectAtIndex:0];
      [pendingFlips removeObjectAtIndex:0];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self performFlipFromView:[self viewToTransitionFromForDirection:flipHolder.direction] toView:[self viewToTransitionToForDirection:flipHolder.direction] withDirection:flipHolder.direction];
      });
    }
  });
  
}

@end


