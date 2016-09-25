#import "MGZPageViewController+MGZFlipSwipePrivate.h"
@import ObjectiveC;

static char *MGZTransitionToInstanceName = "MGZ_viewToTransitionTo";
static char *MGZTransitionFromInstanceName = "MGZ_viewToTransitionFrom";

static char *MGZDirectionInstanceName = "MGZ_direction";
static char *MGZFlipFrontPageInstanceName = "MGZ_flipFrontPage";
static char *MGZPanningInstanceName = "MGZ_panning";
static char *MGZAnimationViewInstanceName = "MGZ_animationView";
static char *MGZLayerFrontInstanceName = "MGZ_layerFront";
static char *MGZLayerFacingInstanceName = "MGZ_layerFacing";
static char *MGZLayerBackInstanceName = "MGZ_layerBack";
static char *MGZLayerRevealInstanceName = "MGZ_layerReveal";
static char *MGZLayerFrontShadowInstanceName = "MGZ_layerFrontShadow";
static char *MGZLayerBackShadowInstanceName = "MGZ_layerBackShadow";
static char *MGZLayerFacingShadowInstanceName = "MGZ_layerFacingShadow";
static char *MGZLayerRevealShadowInstanceName = "MGZ_layerRevealShadow";

@implementation MGZPageViewController (MGZFlipSwipePrivate)

#pragma mark - State Accessors

- (MGZViewAnimationDirection)direction
{
  id	theObject = objc_getAssociatedObject(self, MGZDirectionInstanceName);
  return (MGZViewAnimationDirection)[theObject integerValue];
}

- (void)setDirection:(MGZViewAnimationDirection)direction
{
  objc_setAssociatedObject(self, MGZDirectionInstanceName, [NSNumber numberWithInteger:direction], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)panning
{
  id	theObject = objc_getAssociatedObject(self, MGZPanningInstanceName);
  return (BOOL)[theObject boolValue];
}

- (void)setPanning:(BOOL)panning
{
  objc_setAssociatedObject(self, MGZPanningInstanceName, [NSNumber numberWithBool:panning], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)flipFrontPage
{
  id	theObject = objc_getAssociatedObject(self, MGZFlipFrontPageInstanceName);
  return (BOOL)[theObject boolValue];
}

- (void)setFlipFrontPage:(BOOL)theFlipFrontPage
{
  objc_setAssociatedObject(self, MGZFlipFrontPageInstanceName, [NSNumber numberWithBool:theFlipFrontPage], OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark - View Accessors

- (UIView *)viewToTransitionTo
{
  id	theView = objc_getAssociatedObject(self, MGZTransitionToInstanceName);
  return (UIView *)theView;
}

- (void)setViewToTransitionTo:(UIView *)newView
{
  objc_setAssociatedObject(self, MGZTransitionToInstanceName, newView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)viewToTransitionFrom
{
  id	theView = objc_getAssociatedObject(self, MGZTransitionFromInstanceName);
  return (UIView *)theView;
}

- (void)setViewToTransitionFrom:(UIView *)newView
{
  objc_setAssociatedObject(self, MGZTransitionFromInstanceName, newView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)animationView
{
  id	theView = objc_getAssociatedObject(self, MGZAnimationViewInstanceName);
  return (UIView *)theView;
}

- (void)setAnimationView:(UIView *)animationView
{
  objc_setAssociatedObject(self, MGZAnimationViewInstanceName, animationView, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Layer Accessors

- (CALayer *)layerFront
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerFrontInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFront:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerFrontInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerFacing
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerFacingInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFacing:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerFacingInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerBack
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerBackInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerBack:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerBackInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerReveal
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerRevealInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerReveal:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerRevealInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CAGradientLayer *)layerFrontShadow
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerFrontShadowInstanceName);
  return (CAGradientLayer *)theObject;
}

- (void)setLayerFrontShadow:(CAGradientLayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerFrontShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CAGradientLayer *)layerBackShadow
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerBackShadowInstanceName);
  return (CAGradientLayer *)theObject;
}

- (void)setLayerBackShadow:(CAGradientLayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerBackShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerFacingShadow
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerFacingShadowInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerFacingShadow:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerFacingShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

- (CALayer *)layerRevealShadow
{
  id	theObject = objc_getAssociatedObject(self, MGZLayerRevealShadowInstanceName);
  return (CALayer *)theObject;
}

- (void)setLayerRevealShadow:(CALayer *)theLayer
{
  objc_setAssociatedObject(self, MGZLayerRevealShadowInstanceName, theLayer, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation MGZPageFlipHolder

- (id)initWithDirection:(MGZViewAnimationDirection)aDirection
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
