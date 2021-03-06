//
//  UIImage+BowerLabsUIKit.m
//  BowerLabsUIKit
//
//  Created by Jeremy Bower on 2013-01-21.
//  Copyright (c) 2013 Bower Labs Inc. All rights reserved.
//

#import "UIImage+BowerLabsUIKit.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImage (BowerLabsUIKit)

+ (UIImage*)bl_imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*)bl_resizableImageNamed:(NSString*)imageName withCapInsets:(UIEdgeInsets)insets
{
    UIImage* image = [UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:insets];
}

- (UIImage*)bl_squareImageWithSides:(CGFloat)sides
{
    return [self bl_squareImageWithSides:sides scale:self.scale];
}

- (UIImage*)bl_squareImageWithSides:(CGFloat)sides scale:(CGFloat)scale
{
    UIImage* sourceImage = self;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    size_t sourceW = CGImageGetWidth(imageRef);
    size_t sourceH = CGImageGetHeight(imageRef);
    
    CGFloat targetSides = sides * scale;
    CGFloat targetScale = (targetSides / MIN(sourceW, sourceH));
    CGFloat targetW = floor(sourceW * targetScale);
    CGFloat targetH = floor(sourceH * targetScale);
    CGFloat targetX = -floor((targetW - targetSides) / 2.0);
    CGFloat targetY = -floor((targetH - targetSides) / 2.0);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, targetSides, targetSides, CGImageGetBitsPerComponent(imageRef), 0, colorSpaceInfo, bitmapInfo);
    if (!bitmap) {
        return nil;
    }
    
    CGContextDrawImage(bitmap, CGRectMake(targetX, targetY, targetW, targetH), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref scale:scale orientation:sourceImage.imageOrientation];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

- (UIImage*)bl_scaleToSize:(CGSize)targetSize
{
    return [self bl_scaleToSize:targetSize scale:self.scale];
}

- (UIImage*)bl_scaleToSize:(CGSize)targetSize scale:(CGFloat)scale
{
    UIImage* sourceImage = self;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGFloat targetWidth = targetSize.width * scale;
    CGFloat targetHeight = targetSize.height * scale;
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), 0, colorSpaceInfo, bitmapInfo);
    if (!bitmap) {
        return nil;
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref scale:scale orientation:sourceImage.imageOrientation];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

- (UIImage*)bl_scaleToMaxSide:(CGFloat)side
{
    return [self bl_scaleToMaxSide:side scale:self.scale];
}

- (UIImage*)bl_scaleToMaxSide:(CGFloat)side scale:(CGFloat)scale
{
    UIImage* sourceImage = self;
    if (MAX(sourceImage.size.width, sourceImage.size.height) <= side) {
        return self;
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    size_t sourceW = CGImageGetWidth(imageRef);
    size_t sourceH = CGImageGetHeight(imageRef);
    
    CGFloat targetSide = side * scale;
    CGFloat targetScale = (targetSide / MAX(sourceW, sourceH));
    CGFloat targetW = (sourceW * targetScale);
    CGFloat targetH = (sourceH * targetScale);
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, targetW, targetH, CGImageGetBitsPerComponent(imageRef), 0, colorSpaceInfo, bitmapInfo);
    if (!bitmap) {
        return nil;
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetW, targetH), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref scale:scale orientation:sourceImage.imageOrientation];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

- (UIImage *)bl_fixOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    if (!ctx) {
        return nil;
    }
    
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage*)bl_setRetinaScaleIfNeeded
{
    if (self.scale == [UIScreen mainScreen].scale) {
        return self;
    }
    
    return [UIImage imageWithCGImage:[self CGImage]
                               scale:[UIScreen mainScreen].scale
                         orientation:self.imageOrientation];
}

- (UIImage *)bl_rasterizedImageWithTintColor:(UIColor *)color
{
    NSParameterAssert(!CGSizeEqualToSize(self.size, CGSizeZero));
    if (self.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect imageBounds = (CGRect){.size=self.size};
    [color setFill];
    [self drawInRect:imageBounds];
    UIImage *rasterizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rasterizedImage;
}

- (NSData *)bl_jpegRepresentationWithQuality:(CGFloat)quality
                                    metadata:(NSDictionary *)metadata
{
    NSMutableData *imageData = [NSMutableData dataWithCapacity:0];
    NSMutableDictionary *imageProps = [metadata mutableCopy];
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef )imageData, kUTTypeJPEG, 1, nil);

    if (imageProps == nil) {
        imageProps = [NSMutableDictionary dictionaryWithCapacity:1];
    }

    [imageProps setObject:@(quality) forKey:(__bridge NSString *)kCGImageDestinationLossyCompressionQuality];

    CGImageDestinationAddImage(dest, self.CGImage, (__bridge CFDictionaryRef )imageProps);

    if (!CGImageDestinationFinalize(dest)) {
        imageData = nil;
    }

    CFRelease(dest);

    return imageData;
}


@end
