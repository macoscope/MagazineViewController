//
//  ANViewController.h
// Michelin Guide
//
//  Created by Bartosz Ciechanowski on 11/14/12.
//  Copyright (c) 2012 Bartosz Ciechanowski. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ANRenderableView.h"

#define DEFAULT_VIEW_ANIMATION_DURATION 0.35f

typedef NS_ENUM(NSInteger, ANViewAnimationDirection) {
    ANViewAnimationDirectionBackward = -1,
    ANViewAnimationDirectionNone = 0,
    ANViewAnimationDirectionForward = 1
};

@interface ANViewController : UIViewController

@property (nonatomic, retain) ANRenderableView *view;

- (void)revealButtonTapped:(id)sender;

@end
