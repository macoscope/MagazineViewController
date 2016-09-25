#import "MGZPageViewController.h"

@interface MGZPageViewController (MGZFlipSwipe)

- (void)performFlipFromView:(UIView *)theFromView
                     toView:(UIView *)theToView
              withDirection:(MGZViewAnimationDirection)aDirection;
- (void)panFlipWithGesture:(UIPanGestureRecognizer *)gestureRecognizer;

@end
