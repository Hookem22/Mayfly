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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    [MFHelpers addTitleBar:self titleText:@"Log in to join events"];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];

    UIImageView *appPic = [[UIImageView alloc] initWithFrame:CGRectMake(80, 80, wd - 160, ht - 200)];
    [appPic setImage:[UIImage imageNamed:@"appScreenshot"]];
    [self addSubview:appPic];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(20, ht - 110, wd - 40, 60)];
    [loginButton setImage:[UIImage imageNamed:@"fbLoginButton"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginButton];
    
    UILabel *disclaimer = [[UILabel alloc] initWithFrame:CGRectMake(0, ht - 50, wd, 20)];
    disclaimer.text = @"We don't post anything to Facebook";
    [disclaimer setFont:[UIFont systemFontOfSize:14]];
    disclaimer.textAlignment = NSTextAlignmentCenter;
    [self addSubview:disclaimer];
    
}

+(void)facebookLogin
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            //if ([result.grantedPermissions containsObject:@"user_friends"]) {
            // Do work
            //NSLog(@"%@", result);
            //}
        }
    }];
}

-(void)loginButtonClick:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
            [self removeFromSuperview];
        } else {
            
            
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            //if ([result.grantedPermissions containsObject:@"user_friends"]) {
            // Do work
            //NSLog(@"%@", result);
            //}
            
            //Redirect to correct page
            [self removeFromSuperview];
        }
    }];
}

-(void)cancelButtonClick:(id)sender
{
    if(![[self superview] isMemberOfClass:[MFView class]]){
        [MFHelpers closeRight:self.superview];
    }
    [MFHelpers closeRight:self];
}

@end
