//
//  AppTheme.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import "AppTheme.h"

static AppTheme* current;

@implementation AppTheme

#pragma mark - INIT
+ (AppTheme *)currentTheme {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!current)
            current = [AppTheme init];
    });
    
    return current;
}

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}

@end
