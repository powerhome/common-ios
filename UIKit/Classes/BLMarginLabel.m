//
//  BLMarginLabel.m
//  BowerLabsUIKit
//
//  Created by Jeremy Bower on 2013-01-21.
//  Copyright (c) 2013 Bower Labs Inc. All rights reserved.
//

#import "BLMarginLabel.h"

@implementation BLMarginLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    UIEdgeInsets insets = {0, 0, 0, 0};
    self.margins = insets;
    self.automaticallySetPreferredMaxLayoutWidth = NO;
    
    return self;
}

- (void)drawTextInRect:(CGRect)rect 
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.margins)];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    // Helps with autolayout in table view cells.
    if (self.automaticallySetPreferredMaxLayoutWidth && self.preferredMaxLayoutWidth != bounds.size.width) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSStringDrawingOptions options = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    CGSize boundingTextSize = CGSizeMake(MAX(0, size.width - self.margins.left - self.margins.right),
                                         MAX(0, size.height - self.margins.top - self.margins.bottom));
    CGSize boundingSize = [self.attributedText boundingRectWithSize:boundingTextSize
                                                            options:options
                                                            context:nil].size;
    CGFloat width = ceil(boundingSize.width + self.margins.left + self.margins.right);
    CGFloat height = ceil(boundingSize.height + self.margins.top + self.margins.bottom);
    
    return CGSizeMake(MAX(0, width), MAX(0, height));
}

@end
