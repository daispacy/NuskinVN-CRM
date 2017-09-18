//
//  AppCoreData.m
//  MobileConciergeUSDemo
//
//  Created by Dai Pham on 8/13/17.
//  Copyright © 2017 Sunrise Software Solutions Corporation. All rights reserved.
//

#import "AppCoreData.h"
#import "AppDelegate.h"

#define LOCATION_COREDATA   @"Location"

#define LOCATION_TIME_EXPIRED @"LOCATION_TIME_EXPIRED"

@interface AppCoreData() {
    NSArray* listAddress;
    NSMutableArray* listQueues;
    BOOL isStoringNewItem;
}
@end

static AppCoreData* shared;
@implementation AppCoreData

#pragma mark - INIT
+ (AppCoreData *)startService {
    if(!shared) {
        printf("%s",[[NSString stringWithFormat:@"%s\n",__PRETTY_FUNCTION__] UTF8String]);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [AppCoreData new];
        });
    }
    
    shared.onCheckingQueue = ^{
        printf("%s",[[NSString stringWithFormat:@"%s\n",__PRETTY_FUNCTION__] UTF8String]);
        if(shared->listQueues.count > 0) {
            for (NSDictionary* item in shared->listQueues) {
                [shared saveLongitude:[item objectForKey:L_longitude_key] andLatitude:[item objectForKey:L_latitude_key] forAddress:[item objectForKey:L_address_key]];
            }
            [shared->listQueues removeAllObjects];
        }
    };
    
    return shared;
}

- (id) init {
    if(self = [super init]) {
        listQueues = [NSMutableArray new];
    }
    
//    [self resetLocation];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_TIME_EXPIRED]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LOCATION_TIME_EXPIRED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSDate* timeExpired = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_TIME_EXPIRED];
        // after 3 days, system will get new location for addresses
        if([timeExpired timeIntervalSinceNow] < -(3*60*60*24)) {
            
            [self resetLocation];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LOCATION_TIME_EXPIRED];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [self refreshListAddress];
    return self;
}

#pragma mark - STATIC
+ (void) saveLongitude:(NSString *)longitude andLatitude:(NSString *)latitude forAddress:(NSString *)address {
    if(!shared->isStoringNewItem) {
        [shared saveLongitude:longitude andLatitude:latitude forAddress:address];
//        NSLog(@"%s for address: %@",__PRETTY_FUNCTION__,address);
    } else {
        [shared->listQueues addObject:@{L_longitude_key:longitude,
                                        L_latitude_key:latitude,
                                        L_address_key:address
                                        }];
        NSLog(@"%s add address to queue: %@",__PRETTY_FUNCTION__,address);
    }
}

+ (id)getLocationForAddress:(NSString *)address {
    if(!shared)
        return nil;
    
    return [shared getLocationFromAddress:address];
}

#pragma mark - PRIVATE
- (void) saveLongitude:(NSString*)longitude andLatitude:(NSString*) latitude forAddress:(NSString*)address {
    if([self getLocationFromAddress:address]) {
       return;
    }
    if(isStoringNewItem) {
        [listQueues addObject:@{L_longitude_key:longitude,
                                        L_latitude_key:latitude,
                                        L_address_key:address
                                        }];
        return;
    }
    
    isStoringNewItem = YES;
    NSManagedObjectContext *context = [self managedObjectContext];
    // Create a new managed object
    NSManagedObject* location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];

    [location setValue:[NSString stringWithFormat:@"%@",longitude] forKey:L_longitude_key];
    [location setValue:[NSString stringWithFormat:@"%@",latitude] forKey:L_latitude_key];
    [location setValue:[NSString stringWithFormat:@"%@",address] forKey:L_address_key];
    
    // Save the object to persistent store
    NSError* error;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    isStoringNewItem = NO;
    [self refreshListAddress];
    if(_onCheckingQueue)
        _onCheckingQueue();
}

- (id) getLocationFromAddress:(NSString*) address {
    if(listAddress.count == 0)
        return nil;
    
    for (NSManagedObject* item in [listAddress reverseObjectEnumerator]) {
        if([[item valueForKey:L_address_key] isEqualToString:address]) {
            
            return @{L_longitude_key:[item valueForKey:L_longitude_key],
                     L_latitude_key:[item valueForKey:L_latitude_key]};
        }
    }
    
    return nil;
}

- (void) resetLocation {
    NSManagedObjectContext * context = [self managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Location" inManagedObjectContext:context]];
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    for (id basket in result)
        [context deleteObject:basket];
}

- (void) refreshListAddress {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    listAddress = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
@end
