//
//  NSObject+Wrapper.h
//  MyLocks
//
//  Created by luongnguyen on 7/24/14.
//  Copyright (c) 2014 luongnguyen2506. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Wrapper)

- (void) fillPropertiesWithDictionary:(NSDictionary*)dict;
- (NSDictionary*) getPropertiesDictionary;

- (void) setDetail:(id)value forKey:(NSString*)key;
- (id) getDetailOfKey:(NSString*)key;
- (void) removeDetailOfKey:(NSString*)key;

- (void) setRef:(id)obj forKey:(NSString*)key;
- (id) getRefForKey:(NSString*)key;

- (void) clearAllDetails;

@end
