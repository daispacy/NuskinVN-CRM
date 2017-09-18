//
//  LibUtil.m
//
//  Created by luongnguyen on 9/5/13.
//  Copyright (c) 2013 appiphany. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import <QuartzCore/QuartzCore.h>
#import "LibUtil.h"

@implementation LibUtil

#pragma mark STATIC
+ (void) execBlockMainThread:(void(^)(void))block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void) execBlockConcurrent:(void(^)(void))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

+ (void) execToQueue:(dispatch_queue_t)queue block:(void(^)(void))block
{
    dispatch_async(queue, block);
}

//misc
+ (NSString*) getTimestamp
{
    time_t t;
    time(&t);
    mktime(gmtime(&t));
    int OAuthUTCTimeOffset = 0;
    return [NSString stringWithFormat:@"%lu", t + OAuthUTCTimeOffset];
}

+ (NSString*) getNonce
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge NSString*)s ;
}

+ (NSString*) getUIDStamp
{
    return [NSString stringWithFormat:@"%@-%@",[self getTimestamp],[self getNonce]];
}

+ (NSString*) getBundleInfoOfKey:(NSString*)key
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
}

+ (NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_LONG lng = (CC_LONG) data.length;
    
    CC_SHA1(data.bytes, lng, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;    
}

+ (void) iterateDirectory:(NSString*)dir onReachedFile:(void(^)(id))onReachedFile
{
    NSString* file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:dir];
    while (file = [enumerator nextObject])
    {
        // check if it's a directory
        BOOL isDirectory = NO;
        NSString* fullPath = [dir stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath
                                             isDirectory: &isDirectory];
        if (!isDirectory)
        {
            if (onReachedFile) onReachedFile(fullPath);
        }
        else
        {
            [self iterateDirectory:fullPath onReachedFile:onReachedFile];
        }
    }
}

@end
