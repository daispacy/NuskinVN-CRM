//
//  AuthenticControlller.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/19/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import "AuthenticControlller.h"

@interface AuthenticControlller () <AuthenticViewDelegate,MainServiceDelegate>{
    AuthenticView* authenticView;
}

@end

@implementation AuthenticControlller

#pragma mark - 🚸 INIT 🚸
- (id)initWithAuthenticType:(AuthenticViewType)type {
    if(self = [super init]) {
        authenticView = [[AuthenticView alloc] initWithType:type withDelegate:self];
        [self.view addSubview:authenticView];
        authenticView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:authenticView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:authenticView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:authenticView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:authenticView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

#pragma mark - 🚸 AuthenticView Delegate 🚸
- (void)AuthenticView:(AuthenticView *)view didInvolkeActionWithObject:(NSDictionary *)object andType:(AuthenticViewType)type {
    log(object, YES);
    AuthenticControlller* vc = [[AuthenticControlller alloc] initWithAuthenticType:AUTH_LOGIN];
    [Support changeRootControllerTo:vc withAnimation:YES];
}

@end
