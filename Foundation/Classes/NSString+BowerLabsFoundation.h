//
//  NSString+BowerLabsFoundation.h
//  BowerLabsFoundation
//
//  Created by Jeremy Bower on 2013-01-21.
//  Copyright (c) 2013 Bower Labs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BowerLabsFoundation)

+ (NSString*)stringWithUUID;
+ (NSString*)stringWithData:(NSData*)data encoding:(NSStringEncoding)encoding;

- (NSString*)stringByCapitalizingFirstLetter;

- (NSString*)trimWhitespace;
- (NSString*)nilForEmptyString;

- (NSString*)formatPhoneNumber;

- (NSDate*)dateValue;

@end
