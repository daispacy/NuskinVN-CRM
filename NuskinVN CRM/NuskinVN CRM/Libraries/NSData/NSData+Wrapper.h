//
//  NSData+Wrapper.h
//
//  Created by luongnguyen on 7/22/14.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSData.h>

@class NSString;

@interface NSData (Wrapper)

+ (NSData *) dataFromBase64String: (NSString *) base64String;
- (id) initWithBase64String: (NSString *) base64String;
- (NSString *) base64EncodedString;

- (NSString*) toString;

@end
