//
//  NSTimer+Wrapper.h
//
//
//  Created by luongnguyen on 7/23/14.
//  Copyright (c) 2014 appiphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Wrapper)

#pragma mark STATIC
+ (NSTimer*) timerWithInterval:(float)f andBlock:(void(^)(NSTimer*))block;
+ (NSTimer*) timerWithTimeoutMain:(float)f andBlock:(void(^)(NSTimer*))block;

+ (NSTimer*) timerWithTimeout:(float)f andBlock:(void(^)(NSTimer*))block;

+ (NSTimer*) timerWithIntervalX:(float)f andBlock:(void(^)(NSTimer*))block;

@end
