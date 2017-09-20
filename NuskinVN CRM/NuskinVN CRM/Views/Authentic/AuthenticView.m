//
//  AuthenticView.m
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/18/17.
//  Copyright © 2017 Derasoft. All rights reserved.
//

#import "Support.h"

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
    
    BOOL isRememberAccount;
}
@end

@implementation AuthenticView

#pragma mark - 🚸 INIT 🚸
- (id)initWithType:(AuthenticViewType)t
      withDelegate:(id<AuthenticViewDelegate>)delegate {
    
    if(self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        type = t;
        if(delegate)
            delegate_ =delegate;
    }
    
    [self config];
    
    return self;
}

#pragma mark - 🚸 EVENT 🚸
- (void) buttonPress:(UIButton*) button {
    if ([button isEqual:btnCheckBox]) {
        button.selected = !button.selected;
        isRememberAccount = button.selected;
        return;
    }
    
    NSMutableArray* listDatas = [NSMutableArray new];
    switch (type) {
        case AUTH_LOGIN:
            [listDatas addObject:@{@"value":txtPassword.text,@"type":@(VALIDATE_PASSWORD)}];
            [listDatas addObject:@{@"value":txtEmail.text,@"type":@(VALIDATE_EMAIL)}];
            break;
        case AUTH_RESETPASSWORD:
        default:
            [listDatas addObject:@{@"value":txtEmail.text,@"type":@(VALIDATE_EMAIL)}];
            [listDatas addObject:@{@"value":txtVNID.text,@"type":@(VALIDATE_VNID)}];
            break;
    }
    
    [Support validateDatas:listDatas OnDone:^(NSArray* list){
        if([delegate_ respondsToSelector:@selector(AuthenticView:didInvolkeActionWithObject:andType:)]) {
            
            NSMutableDictionary* dict = [NSMutableDictionary new];
            [dict setObject:@(btnCheckBox.selected) forKey:@"remember"];
            
            for (NSDictionary* object in list) {
                if([[object objectForKey:@"type"] integerValue] == VALIDATE_PASSWORD){
                    [dict setObject:[object objectForKey:@"value"] forKey:@"password"];
                } else if([[object objectForKey:@"type"] integerValue] == VALIDATE_EMAIL){
                    [dict setObject:[object objectForKey:@"value"] forKey:@"email"];
                } else if([[object objectForKey:@"type"] integerValue] == VALIDATE_VNID){
                    [dict setObject:[object objectForKey:@"value"] forKey:@"vnID"];
                }
            }
            
            [delegate_ AuthenticView:self didInvolkeActionWithObject:dict andType:type];
        }
    }
                      onFail:^(id error){
        //handle error
                          log(error, NO);
    }];
}

#pragma mark - 🚸 UITEXTFIELD DELEGATE 🚸
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

#pragma mark - 🚸 PRIVATE - set up view🚸
- (void) config {
    
    txtPassword.delegate =  self;
    txtVNID.delegate =      self;
    txtEmail.delegate =     self;
    
    txtEmail.placeholder =      local(@"placeholder_email");
    txtPassword.placeholder =   local(@"placeholder_password");
    txtVNID.placeholder =       local(@"placeholder_vnid");
    lblRemember.text =          local(@"remember_me");
    
    [btnCheckBox setImage:[UIImage imageNamed:@"checkbox_uncheck"]
                 forState:UIControlStateNormal];
    [btnCheckBox setImage:[UIImage imageNamed:@"checkbox_check"]
                 forState:(UIControlStateSelected)];
    
    [btnCheckBox addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
    [btnProcess addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [btnProcess setTitle:local(@"Sign_In")
                forState:UIControlStateNormal];
}

- (void) viewWithReset {
    
    [txtPassword setHidden:YES];
    [vwRemember setHidden:YES];
    
    [btnProcess setTitle:local(@"reset_paswword")
                forState:UIControlStateNormal];
}
@end
