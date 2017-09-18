//
//  AppCoreData.h
//  MobileConciergeUSDemo
//
//  Created by Dai Pham on 8/13/17.
//  Copyright © 2017 Sunrise Software Solutions Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define L_address_key       @"address"
#define L_longitude_key     @"longitude"
#define L_latitude_key      @"latitude"

@interface AppCoreData : NSObject

@property (copy) void (^onCheckingQueue)();

+ (AppCoreData*) startService;

+ (void) saveLongitude:(NSString*)longituge andLatitude:(NSString*)latitude forAddress:(NSString*)address;
+ (id) getLocationForAddress:(NSString*) address;
@end
