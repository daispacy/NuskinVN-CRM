//
//  NSTimer+Wrapper.m
//
//
//  Created by luongnguyen on 7/23/14.
//  Copyright (c) 2014 appiphany. All rights reserved.
//

#import "NSTimer+Wrapper.h"

static int countOfTimer__ = 0;

@implementation NSTimer (Wrapper)

#pragma mark STATIC
+ (NSTimer*) timerWithInterval:(float)f andBlock:(void(^)(NSTimer*))block
{
    NSDictionary* d = [NSDictionary dictionaryWithObject:[block copy] forKey:@"FireBlock"];
    NSTimer* tmr = [NSTimer scheduledTimerWithTimeInterval:f  target:self selector:@selector(execWithTimer:) userInfo:d repeats:YES];
    
    countOfTimer__++;

    return tmr;
}

+ (NSTimer*) timerWithTimeoutMain:(float)f andBlock:(void(^)(NSTimer*))block
{
    NSDictionary* d = [NSDictionary dictionaryWithObject:[block copy] forKey:@"FireBlock"];
    NSTimer* tmr = [NSTimer scheduledTimerWithTimeInterval:f  target:self selector:@selector(execWithTimer:) userInfo:d repeats:NO];
    
    countOfTimer__++;

    return tmr;
}

+ (NSTimer*) timerWithTimeout:(float)f andBlock:(void(^)(NSTimer*))block
{
    NSDictionary* d = [NSDictionary dictionaryWithObject:[block copy] forKey:@"FireBlock"];
    NSTimer* tmr = [NSTimer scheduledTimerWithTimeInterval:f  target:self selector:@selector(execWithTimer:) userInfo:d repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:tmr forMode:NSRunLoopCommonModes];

    countOfTimer__++;
    
    return tmr;
}

+ (NSTimer*) timerWithIntervalX:(float)f andBlock:(void(^)(NSTimer*))block
{
    NSDictionary* d = [NSDictionary dictionaryWithObject:[block copy] forKey:@"FireBlock"];
    NSTimer* tmr = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:f target:self selector:@selector(execWithTimer:) userInfo:d repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:tmr forMode:NSRunLoopCommonModes];
    
    countOfTimer__++;

    return tmr;
}

#pragma mark STATIC - SELECTORS
+ (void) execWithTimer:(NSTimer*)tmr
{
    void(^func)(NSTimer*) = [tmr.userInfo objectForKey:@"FireBlock"];
    if (func) func(tmr);
    
    if (![tmr isValid])
    {
        countOfTimer__--;
    }
}

@end
