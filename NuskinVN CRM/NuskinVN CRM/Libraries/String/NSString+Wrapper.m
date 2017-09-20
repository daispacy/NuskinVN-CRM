//
//  NSString+Wrapper.m
//
//
//  Created by luongnguyen on 7/23/14.
//  Copyright (c) 2014 appiphany. All rights reserved.
//

#import "NSString+Wrapper.h"

//**************************************************
static NSMutableDictionary* mapStringToDate__ = nil;

//**************************************************
@implementation NSString (Wrapper)

#pragma mark MAIN
- (NSString*) escapeQuotes
{
//    NSString* s = [self stringByReplacingOccurrencesOfString:@"'" withString:@"{SINGLE_QUOTE}"];
//    s = [s stringByReplacingOccurrencesOfString:@"\"" withString:@"{DOULE_QUOTE}"];

    NSMutableString* ms = [NSMutableString stringWithFormat:@""];
    for (long i = 0; i < self.length; i++)
    {
        NSString* sub = [self substringWithRange:NSMakeRange(i, 1)];
        
        if ([sub isEqualToString:@"#"])
        {
            [ms appendString:@"#0"];
        }
        else if ([sub isEqualToString:@"'"])
        {
            [ms appendString:@"#1"];
        }
        else if ([sub isEqualToString:@"\""])
        {
            [ms appendString:@"#2"];
        }
        else
        {
            [ms appendString:sub];
        }
    }
    return ms;
}

- (NSString*) unescapeQuotes
{
//    NSString* s = [self stringByReplacingOccurrencesOfString:@"{SINGLE_QUOTE}" withString:@"'"];
//    s = [s stringByReplacingOccurrencesOfString:@"{DOULE_QUOTE}" withString:@"\""];
    if (self.length < 2) return self;
    if ([self rangeOfString:@"#"].location == NSNotFound) return self;
    
    NSMutableString* ms = [NSMutableString stringWithFormat:@""];
    long i = 0;
    for (i = 0; i < self.length; i++)
    {
        int range = 2;
        if (i > self.length-2) range = 1;
        
        NSString* sub = [self substringWithRange:NSMakeRange(i, range)];
        
        if ([sub isEqualToString:@"#2"])
        {
            [ms appendString:@"\""];
            i++;
        }
        else if ([sub isEqualToString:@"#1"])
        {
            [ms appendString:@"'"];
            i++;
        }
        else if ([sub isEqualToString:@"#0"])
        {
            [ms appendString:@"#"];
            i++;
        }
        else
        {
            if (range == 2)
                [ms appendString:[sub substringToIndex:1]];
            else
                [ms appendString:sub];
        }
    }
        
    return ms;
}

-(BOOL)isValidEmail
{
    if(self.length > 150)
    {
        return NO;
    }
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@{1}([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
@end
