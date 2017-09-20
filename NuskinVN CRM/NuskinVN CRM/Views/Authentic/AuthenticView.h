//
//  AuthenticView.h
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AUTH_RESETPASSWORD = 0,
    AUTH_LOGIN,
} AuthenticViewType;

@class AuthenticView;

@protocol AuthenticViewDelegate<NSObject>

- (void) AuthenticView:(AuthenticView*) view didInvolkeActionWithObject:(NSDictionary*)object andType:(AuthenticViewType)type;

@end

@interface AuthenticView : UIView

#pragma mark - 🚸 INTERFACE 🚸
- (id) initWithType:(AuthenticViewType)t withDelegate:(id<AuthenticViewDelegate>) delegate;

@end
