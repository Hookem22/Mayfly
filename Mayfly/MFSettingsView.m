//
//  MFSettingsView.m
//  Pow Wow
//
//  Created by Will Parks on 2/9/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFSettingsView.h"

@implementation MFSettingsView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    [self setup];
    
    return self;
}

-(void)setup {

    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.frame = CGRectMake(0, 0, wd, ht);
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer1];
    
    [MFHelpers addTitleBar:self titleText:@"Settings"];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    int viewY = 60;
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 140)];
    [self addSubview:userView];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake((wd - 80) / 2, 15, 80, 80) facebookId:currentUser.facebookId];
    [userView addSubview:pic];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, wd, 20)];
    [nameLabel setText:currentUser.firstName];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [userView addSubview:nameLabel];
    viewY += 140;
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY - 1, wd, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self addSubview:borderView];
    viewY += 10;
    
    UILabel *calendarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewY, wd, 20)];
    calendarLabel.text = @"Add events to my calendar:";
    calendarLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:calendarLabel];
    viewY += 25;
    
    UIView *calendarBorderView = [[UIView alloc] initWithFrame:CGRectMake(20, viewY, wd - 40, 40)];
    [calendarBorderView.layer setBorderColor:[[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] CGColor]];
    [calendarBorderView.layer setBorderWidth:1.0];
    calendarBorderView.layer.cornerRadius = 12.0;
    [self addSubview:calendarBorderView];
    
    UIButton *alwaysButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    alwaysButton.frame = CGRectMake(21, viewY + 1, ((wd - 42) / 3), 38);
    [alwaysButton setTitle:@"Always" forState:UIControlStateNormal];
    [alwaysButton addTarget:self action:@selector(calendarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    alwaysButton.tag = 1;
    [self addSubview:alwaysButton];
    
    CAShapeLayer * leftMask = [CAShapeLayer layer];
    leftMask.path = [UIBezierPath bezierPathWithRoundedRect: alwaysButton.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){10.0, 10.}].CGPath;
    alwaysButton.layer.mask = leftMask;
    
    UIButton *askMeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    askMeButton.frame = CGRectMake(((wd - 40) / 3) + 20, viewY, ((wd - 40) / 3), 40);
    [askMeButton setTitle:@"Ask Me" forState:UIControlStateNormal];
    [askMeButton addTarget:self action:@selector(calendarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [askMeButton.layer setBorderColor:[[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] CGColor]];
    [askMeButton.layer setBorderWidth:1.0];
    askMeButton.tag = 2;
    [self addSubview:askMeButton];
    
    UIButton *neverButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    neverButton.frame = CGRectMake((((wd - 40) * 2) / 3) + 20, viewY + 1, ((wd - 40) / 3), 38);
    [neverButton setTitle:@"Never" forState:UIControlStateNormal];
    [neverButton addTarget:self action:@selector(calendarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    neverButton.tag = 3;
    [self addSubview:neverButton];
    
    CAShapeLayer * rightMask = [CAShapeLayer layer];
    rightMask.path = [UIBezierPath bezierPathWithRoundedRect: neverButton.bounds byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.}].CGPath;
    neverButton.layer.mask = rightMask;
    
    int tag = currentUser.addToCalendar == 0 ? 2 : currentUser.addToCalendar;
    [self changeCalenderPicker:tag];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(30, ht - 50, wd - 60, 40)];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    [self addSubview:loginButton];
}

-(void)calendarButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = (int)button.tag;
    [self changeCalenderPicker:tag];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    currentUser.addToCalendar = tag;

    [currentUser save:^(User *user) {
        //[[Session sessionVariables] setObject:user forKey:@"currentUser"];
    }];
}

-(void)changeCalenderPicker:(int)tagId {
    for(UIView *subview in self.subviews) {
        if([subview isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if(subview.tag == tagId) {
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.layer.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
            }
            else if(subview.tag == 1 || subview.tag == 2 || subview.tag == 3) {
                [button setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                button.layer.backgroundColor = [UIColor whiteColor].CGColor;
            }
        }
    }
}

-(void)cancelButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(wd, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)nothing:(id)sender {
    
}

@end
