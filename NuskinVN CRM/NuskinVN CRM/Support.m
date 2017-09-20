//
//  Support.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/19/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import "Support.h"

@implementation Support

/**
 Change root viewcontroller with animation
 
 @param vc view controller become root
 @param is animation if Yes|True
 */
+ (void) changeRootControllerTo:(id)vc withAnimation:(BOOL)is{
    if(![vc isKindOfClass:[UINavigationController class]] &&
       ![vc isKindOfClass:[UIViewController class]] &&
       ![vc isKindOfClass:[UITabBarController class]]) {
        printf("%s",[[NSString stringWithFormat:@"%s\n",__PRETTY_FUNCTION__] UTF8String]);
        return;
    }
    
    NSString* str = [NSString stringWithFormat:@"%@",[vc class]];
    log(str, TRUE);
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [UIView transitionWithView:appDelegate.window
                      duration:is?0.5:0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        appDelegate.window.rootViewController = vc;
                        [appDelegate.window makeKeyAndVisible];
                        
                    }
                    completion:nil];
}

/**
 validate array object {include value, type validate}

 @param listData array store objects need validate
 @param onDone block onDone involke if success
 @param onFail block onFail involke if failed
 */
+ (void) validateDatas:(NSArray*)listData OnDone:(void(^)(id))onDone onFail:(void(^)(id))onFail{
    
    if(listData.count == 0)
        return;
    
    NSMutableArray* returnObjects = [NSMutableArray new];

    for (NSDictionary* object in listData) {
        switch ([[object objectForKey:@"type"] integerValue]) {
            case VALIDATE_EMAIL: {
                NSString* email = [object objectForKey:@"value"];
                [returnObjects addObject:@{@"value":email,@"type":@(VALIDATE_EMAIL),@"valid":@([email isValidEmail])}];
            } break;
            case VALIDATE_PASSWORD: {
                NSString* password = [object objectForKey:@"value"];
                [returnObjects addObject:@{@"value":password,@"type":@(VALIDATE_PASSWORD),@"valid":@(password.length > 5)}];
            } break;
            case VALIDATE_VNID: {
                NSString* value = [object objectForKey:@"value"];
                [returnObjects addObject:@{@"value":value,@"type":@(VALIDATE_VNID),@"valid":@(value.length > 5)}];
            }break;
        }
    }
    
    BOOL isFalse = NO;
    for (NSDictionary* obj in returnObjects) {
        if(![[obj objectForKey:@"valid"] boolValue]) {
            isFalse = YES;
            break;
        }
    }
    if(isFalse) {
        if(onFail)
            onFail(returnObjects);
    } else {
        if(onDone)
            onDone(returnObjects);
    }
}
@end
