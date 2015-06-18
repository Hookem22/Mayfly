//
//  MFLoginView.m
//  Mayfly
//
//  Created by Will Parks on 5/21/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFLoginView.h"

@implementation MFLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 20, 60, 20);
    [self addSubview:cancelButton];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, (ht / 2) - 30, wd - 40, 60)];
    [loginButton setImage:[UIImage imageNamed:@"fbLoginButton"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginButton];
    
}

-(void)loginButtonClick:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            
            
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            //if ([result.grantedPermissions containsObject:@"user_friends"]) {
            // Do work
            //NSLog(@"Yes");
            //}
            
            //Redirect to correct page
            [self removeFromSuperview];
        }
    }];
}

-(void)cancelButtonClick:(id)sender
{
    [MFHelpers close:self.superview];
    [MFHelpers close:self];
}

@end
