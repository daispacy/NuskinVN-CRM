//
//  ImageCacheList.m
//  ALC
//
//  Created by Dai Pham on 5/12/17.
//  Copyright © 2017 Sunrise Software Solutions. All rights reserved.
//

#import "ImageCacheList.h"

@implementation ImageCacheList
static ImageCacheList *_cache;

+ (id) cache {
    static dispatch_once_t onceToken;
    if(!_cache) {
        dispatch_once(&onceToken, ^{
            _cache = [ImageCacheList new];
        });
    }
    return _cache;
}

- (instancetype) init {
    if(self == [super init]) {
        
    }
    return self;
}
@end
