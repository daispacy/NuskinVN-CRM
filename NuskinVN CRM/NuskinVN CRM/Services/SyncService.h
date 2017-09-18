//
//  SyncService.h
//  USDemo
//
//  Created by Dai Pham on 6/7/17.
//  Copyright (c) 2017. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncService : NSObject

#pragma mark STATIC - API
+ (void) postUrl:(NSString*) url withParams:(NSDictionary*) params OnDone:(void(^)(id))onDone onError:(void(^)(id))onError;
+ (void) getUrl:(NSString*) url withParams:(NSDictionary*) params OnDone:(void(^)(id))onDone onError:(void(^)(id))onError;
+ (void) getUrl:(NSString *)url withTimeout:(NSTimeInterval)timeoutInterval withParams:(NSDictionary *)params OnDone:(void (^)(id))onDone onError:(void (^)(id))onError;
@end
