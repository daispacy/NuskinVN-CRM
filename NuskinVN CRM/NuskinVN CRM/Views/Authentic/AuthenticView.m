//
//  AuthenticView.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import "Constant.h"

#import "AuthenticView.h"

@interface AuthenticView ()<UITextFieldDelegate> {
    
    IBOutlet UIStackView *stackView;
    IBOutlet UITextField *txtVNID;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UIView *vwRemember;
    IBOutlet UIButton *btnCheckBox;
    IBOutlet UILabel *lblRemember;
    IBOutlet UIButton *btnProcess;
    
    __weak id<AuthenticViewDelegate> delegate_;
    
    AuthenticViewType type;
}
@end

@implementation AuthenticView

#pragma mark - 🚸 INIT 🚸
- (id)initWithType:(AuthenticViewType)t
      withDelegate:(id<AuthenticViewDelegate>)delegate {
    
    if(self = [super init]) {
        type = t;
        if(delegate)
            delegate_ =delegate;
    }
    
    [self config];
    
    return self;
}

#pragma mark - 🚸 EVENT 🚸
- (void) buttonPress:(UIButton*) button {
    [self validateDataOnDone:^(id object){
        if([delegate_ respondsToSelector:@selector(AuthenticView:didInvolkeActionWithObject:)]) {
            [delegate_ AuthenticView:self didInvolkeActionWithObject:object];
        }
    }
                      onFail:^(id error){
        //handle error
                          
    }];
}

#pragma mark - 🚸 UITEXTFIELD DELEGATE 🚸
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

#pragma mark - 🚸 PRIVATE 🚸
- (void) config {
    
    txtPassword.delegate =  self;
    txtVNID.delegate =      self;
    txtEmail.delegate =     self;
    
    txtEmail.placeholder =      local(@"placeholder_email");
    txtPassword.placeholder =   local(@"placeholder_password");
    txtVNID.placeholder =       local(@"placeholder_vnid");
    lblRemember.text =          local(@"remember_me");
    
    [btnCheckBox setImage:[UIImage imageNamed:@"checkbox_uncheck"] forState:UIControlStateNormal];
    [btnCheckBox setImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateSelected];
    
    [btnProcess addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    //config view with type
    switch (type) {
        case AUTH_LOGIN:
            [self viewWithLogin];
            break;
        case AUTH_RESETPASSWORD:
        default:
            [self viewWithReset];
            break;
    }
}

- (void) viewWithLogin {
    
    [txtVNID setHidden:YES];
    
    [btnProcess setTitle:local(@"sigin_in") forState:UIControlStateNormal];
}

- (void) viewWithReset {
    
    [txtPassword setHidden:YES];
    [vwRemember setHidden:YES];
    
    [btnProcess setTitle:local(@"reset_paswword") forState:UIControlStateNormal];
}

- (void) validateDataOnDone:(void(^)(id))onDone onFail:(void(^)(id))onFail{
    
}
@end
