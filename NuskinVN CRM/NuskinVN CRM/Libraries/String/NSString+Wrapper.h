//
//  NSString+Wrapper.h
//
//
//  Created by luongnguyen on 7/23/14.
//  Copyright (c) 2014 appiphany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Wrapper)

#pragma mark MAIN
- (NSString*) escapeQuotes;
- (NSString*) unescapeQuotes;

@end
