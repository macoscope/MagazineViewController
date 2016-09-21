//
//  ANRenderableView.h
// Michelin Guide
//
//  Created by Jarosław Pendowski on 24.06.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANRenderableView : UIView
@property (strong, readonly) UIImage *fullRender;
@property (nonatomic, readonly) CGImageRef leftHalf;
@property (nonatomic, readonly) CGImageRef rightHalf;
@property (nonatomic) CGFloat renderScale;

- (void)renderImageHalfsForFlipping;
- (void)clearImageHalfs;
- (void)setDirty;

@end
