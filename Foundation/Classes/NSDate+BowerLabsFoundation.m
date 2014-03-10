//
//  NSDate+BowerLabsFoundation.m
//  BowerLabsFoundation
//
//  Created by Jeremy Bower on 2013-01-21.
//  Copyright (c) 2013 Bower Labs Inc. All rights reserved.
//

#import "NSDate+BowerLabsFoundation.h"

@implementation NSDate (BowerLabsFoundation)

+ (NSDate*)bl_dateWithRFCFormattedString:(NSString*)value
{
    if (!value) {
        return nil;
    }
    
    NSDate* date = nil;
    if ((date = [self bl_dateWithRFCFormattedStringA:value]) ||
        (date = [self bl_dateWithRFCFormattedStringB:value]))
    {
        return date;
    }
    
    NSLog(@"Failed to parse RFC formatted datetime: %@", value);
    return nil;
}

+ (NSDate*)bl_dateWithRFCFormattedStringA:(NSString*)value
{
    // Create a shared formatter.
    static NSRegularExpression* regex = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})Z" options:0 error:nil];
    });
    
    // Match the string.
    NSTextCheckingResult* result = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
    if (result) {
        NSDateComponents* components = [[NSDateComponents alloc] init];
        components.year =   [[value substringWithRange:[result rangeAtIndex:1]] integerValue];
        components.month =  [[value substringWithRange:[result rangeAtIndex:2]] integerValue];
        components.day =    [[value substringWithRange:[result rangeAtIndex:3]] integerValue];
        components.hour =   [[value substringWithRange:[result rangeAtIndex:4]] integerValue];
        components.minute = [[value substringWithRange:[result rangeAtIndex:5]] integerValue];
        components.second = [[value substringWithRange:[result rangeAtIndex:6]] integerValue];
        
        components.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        return [calendar dateFromComponents:components];
    }
    
    return nil;
}

+ (NSDate*)bl_dateWithRFCFormattedStringB:(NSString*)value
{
    // Create a shared formatter.
    static NSRegularExpression* regex = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})([\\+-])(\\d{2}):?(\\d{2})" options:0 error:nil];
    });
    
    // Match the string.
    NSTextCheckingResult* result = [regex firstMatchInString:value options:0 range:NSMakeRange(0, value.length)];
    if (result) {
        NSDateComponents* components = [[NSDateComponents alloc] init];
        components.year =   [[value substringWithRange:[result rangeAtIndex:1]] integerValue];
        components.month =  [[value substringWithRange:[result rangeAtIndex:2]] integerValue];
        components.day =    [[value substringWithRange:[result rangeAtIndex:3]] integerValue];
        components.hour =   [[value substringWithRange:[result rangeAtIndex:4]] integerValue];
        components.minute = [[value substringWithRange:[result rangeAtIndex:5]] integerValue];
        components.second = [[value substringWithRange:[result rangeAtIndex:6]] integerValue];
        
        NSInteger offsetSign = ([[value substringWithRange:[result rangeAtIndex:7]] isEqualToString:@"-"] ? -1 : 1);
        NSInteger offsetHoursComponent = [[value substringWithRange:[result rangeAtIndex:8]] integerValue];
        NSInteger offsetMinutesComponent = [[value substringWithRange:[result rangeAtIndex:9]] integerValue];
        NSInteger offsetSeconds = offsetSign * ((offsetHoursComponent * 60 * 60) + (offsetMinutesComponent * 60));
        components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:offsetSeconds];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        return [calendar dateFromComponents:components];
    }
    
    return nil;
}

+ (NSDate*)bl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [self bl_dateWithYear:year month:month day:day calendar:calendar];
}

+ (NSDate*)bl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day calendar:(NSCalendar*)calendar
{
    NSDateComponents* components = [[NSDateComponents alloc]  init];
    components.year = year;
    components.month = month;
    components.day = day;
    components.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [calendar dateFromComponents:components];
}

+ (NSDate*)bl_today
{
    return [[NSDate date] bl_startOfDay];
}

+ (NSDate*)bl_tomorrow
{
    NSDate* today = [NSDate bl_today];
    
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:comps toDate:today options:0];
}

+ (NSDate*)bl_yesterday
{
    NSDate* today = [NSDate bl_today];
    
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:comps toDate:today options:0];
}

- (NSDate*)bl_startOfDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger unitFlags = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSTimeZoneCalendarUnit);
    NSDateComponents *comps = [cal components:unitFlags fromDate:self];
    return [cal dateFromComponents:comps];
}

- (BOOL)bl_isBefore:(NSDate *)date
{
    return self.timeIntervalSinceReferenceDate < date.timeIntervalSinceReferenceDate;
}

- (BOOL)bl_isAfter:(NSDate *)date
{
    return self.timeIntervalSinceReferenceDate > date.timeIntervalSinceReferenceDate;
}

- (BOOL)bl_isEqualOrBefore:(NSDate*)date
{
    return self.timeIntervalSinceReferenceDate <= date.timeIntervalSinceReferenceDate;
}

- (BOOL)bl_isEqualOrAfter:(NSDate*)date
{
    return self.timeIntervalSinceReferenceDate >= date.timeIntervalSinceReferenceDate;
}

@end
