//
//  MainService.h
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MainService;

@protocol MainServiceDelegate

@end

@interface MainService : NSObject
- (id) initWithDelegate:(id<MainServiceDelegate>) delegate;
@end
