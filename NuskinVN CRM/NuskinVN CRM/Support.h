//
//  Support.h
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/19/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    VALIDATE_EMAIL,
    VALIDATE_PASSWORD,
    VALIDATE_VNID,
} ValidateType;


//cosntant
#import "Constant.h"

// wrapper
#import "NSString+Wrapper.h"
#import "NSTimer+Wrapper.h"

// service
#import "MainService.h"

// appdelegate
#import "AppDelegate.h"

// theme
#import "AppTheme.h"

@interface Support : NSObject

+ (void) changeRootControllerTo:(id) vc withAnimation:(BOOL) is;

+ (void) validateDatas:(NSArray*)listData OnDone:(void(^)(id))onDone onFail:(void(^)(id))onFail;
@end
