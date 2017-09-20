//
//  MainService.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

// service
#import "SyncService.h"
#import "LocalService.h"

#import "MainService.h"

@interface MainService () {
    __weak id<MainServiceDelegate> delegate_;
}

@end

@implementation MainService

#pragma mark - 🚸 INIT 🚸
- (id)initWithDelegate:(id<MainServiceDelegate>)delegate {
    if(self = [super init]) {
        delegate_ = delegate;
    }
    return self;
}

@end
