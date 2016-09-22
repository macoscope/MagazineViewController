//
//  UIView.h
// Michelin Guide
//
//  Created by Jarosław Pendowski on 24.06.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

@import UIKit;

@interface UIView (Rendering)
@property (nonatomic, strong, readonly) UIImage *fullRender;
@property (nonatomic, readonly) CGImageRef leftHalf;
@property (nonatomic, readonly) CGImageRef rightHalf;
@property (nonatomic, readonly) CGFloat renderScale;

- (void)renderImageHalfsForFlipping;
- (void)clearImageHalfs;

@end
