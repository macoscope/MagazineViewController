@import UIKit;

@interface UIView (Rendering)
@property (nonatomic, strong, readonly) UIImage *mgz_fullRender;
@property (nonatomic, readonly) CGImageRef mgz_leftHalf;
@property (nonatomic, readonly) CGImageRef mgz_rightHalf;
@property (nonatomic, readonly) CGFloat mgz_renderScale;

- (void)mgz_renderImageHalfsForFlipping;
- (void)mgz_clearImageHalfs;

@end
