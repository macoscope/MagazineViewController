#import "MGZPageViewController.h"

#define MARGIN	75
#define ANGLE	90

#define SWIPE_LEFT_THRESHOLD -50.0f
#define SWIPE_RIGHT_THRESHOLD 50.0f

static inline double radians (double degrees) {return degrees * M_PI/180;}
static inline double degrees (double radians) {return radians * 180/M_PI;}

@interface MGZPageViewController (MGZFlipSwipePrivate)

@property (nonatomic, retain) UIView *viewToTransitionFrom;
@property (nonatomic, retain) UIView *viewToTransitionTo;

@property (assign) MGZViewAnimationDirection direction;
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

@interface MGZPageFlipHolder : NSObject
@property MGZViewAnimationDirection direction;
@property BOOL hasGoneToFlip;
@property NSTimeInterval createdAt;
- (id)initWithDirection:(MGZViewAnimationDirection)aDirection;
@end

@interface UIView (MGZRenderImage)
- (UIImage *)renderImageWithRect:(CGRect)frame;
@end


