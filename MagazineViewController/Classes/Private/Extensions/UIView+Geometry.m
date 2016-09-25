#import "UIView+Geometry.h"

@implementation UIView (Geometry)

- (CGFloat)mgz_width {
  return CGRectGetWidth(self.frame);
}

- (CGFloat)mgz_height {
  return CGRectGetHeight(self.frame);
}

@end
