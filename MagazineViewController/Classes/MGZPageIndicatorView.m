#import "MGZPageIndicatorView.h"

@interface MGZPageIndicatorView ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *pageNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPagesLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleTextLabel;

@end

@implementation MGZPageIndicatorView

- (void)setupWithNumberOfPages:(NSInteger)numberOfPages pageNumber:(NSInteger)pageNumber
{
  self.pageNumberLabel.text = [@(pageNumber + 1) stringValue];
  self.numberOfPagesLabel.text = [@(numberOfPages) stringValue];
  self.middleTextLabel.text = NSLocalizedString(@"of", nil);
}

@end
