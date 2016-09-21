//
//  ANPageIndicatorView.m
// Michelin Guide
//
//  Created by Rafal Augustyniak on 09.10.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "ANPageIndicatorView.h"

@interface ANPageIndicatorView ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleTextLabel;

@end

@implementation ANPageIndicatorView

- (void)setupWithNumberOfPages:(NSInteger)numberOfPages pageNumber:(NSInteger)pageNumber
{
  self.pageNumberLabel.text = [@(pageNumber + 1) stringValue];
  self.numberOfPagesLabel.text = [@(numberOfPages) stringValue];
  self.middleTextLabel.text = NSLocalizedString(@"of", nil);
}

@end
