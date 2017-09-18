//
//  SyncService.h
//  USDemo
//
//  Created by Dai Pham on 6/7/17.
//  Copyright (c) 2017. All rights reserved.
//


//app
#import "SyncService.h"
#import "AFHTTPRequestOperationManager.h"

#define MSG_SERVER_WRONG            local(@"I'm currently having trouble connecting to the server. Please try again shortly.")

//**************************************************
@interface AFHTTPRequestOperationManager (Timeout)

- (AFHTTPRequestOperation*)POST:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError* error))failure;
@end

@implementation AFHTTPRequestOperationManager (Timeout)

- (AFHTTPRequestOperation*) POST:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError* error))failure;
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:NULL];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation*) GET:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError* error))failure;
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:NULL];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}
@end

//**************************************************
@interface SyncService ()@end

@implementation SyncService

#pragma mark STATIC - API register device, get user info of device
+ (void)postUrl:(NSString *)url withParams:(NSDictionary *)params OnDone:(void (^)(id))onDone onError:(void (^)(id))onError {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSLog(@"%s: %@%@",__PRETTY_FUNCTION__,url,params);
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    [manager setResponseSerializer:serializer];
    
    [manager POST:url parameters:params timeoutInterval:60 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(onDone) {
            onDone(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(onError)
        {
            onError(error);
        }
    }];
}

+ (void)getUrl:(NSString *)url withParams:(NSDictionary *)params OnDone:(void (^)(id))onDone onError:(void (^)(id))onError {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(onDone) {
            onDone(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(onError)
        {
            onError(error);
        }
    }];
    
}

+ (void)getUrl:(NSString *)url withTimeout:(NSTimeInterval)timeoutInterval withParams:(NSDictionary *)params OnDone:(void (^)(id))onDone onError:(void (^)(id))onError {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager GET:url parameters:params timeoutInterval:timeoutInterval success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(onDone) {
            onDone(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(onError)
        {
            onError(error);
        }
    }];
    
}
@end
