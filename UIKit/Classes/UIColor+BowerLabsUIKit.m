//
//  UIColor+BowerLabsUIKit.m
//  BowerLabsUIKit
//
//  Created by Jeremy Bower on 2013-01-21.
//  Copyright (c) 2013 Bower Labs Inc. All rights reserved.
//

#import "UIColor+BowerLabsUIKit.h"

@implementation UIColor (BowerLabsUIKit)

+ (UIColor*)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha
{
    CGFloat r = ((hex & 0x00FF0000) >> 16) / 255.0;
    CGFloat g = ((hex & 0x0000FF00) >> 8) / 255.0;
    CGFloat b = (hex & 0x000000FF) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

@end