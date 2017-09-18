//
//  LibUtil.h
//
//  Created by luongnguyen on 9/5/13.
//  Copyright (c) 2013 appiphany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LibUtil : NSObject
{    
}

#pragma mark STATIC
+ (void) execBlockMainThread:(void(^)(void))block;
+ (void) execBlockConcurrent:(void(^)(void))block;

+ (void) execToQueue:(dispatch_queue_t)queue block:(void(^)(void))block;

//misc
+ (NSString*) getTimestamp;
+ (NSString*) getNonce;

+ (NSString*) getUIDStamp;

+ (NSString*) getBundleInfoOfKey:(NSString*)key;
+ (NSString*) sha1:(NSString*)input;

+ (void) iterateDirectory:(NSString*)dir onReachedFile:(void(^)(id))onReachedFile;

#pragma mark MAIN

@end
