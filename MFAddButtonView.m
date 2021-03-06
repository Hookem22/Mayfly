//
//  MFAddButtonView.m
//  Pow Wow
//
//  Created by Will Parks on 2/5/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFAddButtonView.h"

@interface MFAddButtonView()

@property (nonatomic, strong) UIButton* eventButton;
@property (nonatomic, strong) UIButton* postButton;
@property (nonatomic, strong) UIButton* interestButton;
@property (nonatomic, strong) UIButton* closeButton;
@property (nonatomic, strong) UILabel* eventLabel;
@property (nonatomic, strong) UILabel* postLabel;
@property (nonatomic, strong) UILabel* interestLabel;

@end

@implementation MFAddButtonView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.75];
    [self setup];
    
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeButtonClick:)];
    [self addGestureRecognizer:singleTap];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    self.eventButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-60, 60, 60)];
    [self.eventButton setImage:[UIImage imageNamed:@"addevent"] forState:UIControlStateNormal];
    [self.eventButton addTarget:self action:@selector(eventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.eventButton];
    
    self.eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd/4, ht, wd/2, 20)];
    self.eventLabel.text = @"Event";
    self.eventLabel.textColor = [UIColor whiteColor];
    self.eventLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.eventLabel];
    
    self.postButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-60, 60, 60)];
    [self.postButton setImage:[UIImage imageNamed:@"addpost"] forState:UIControlStateNormal];
    [self.postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.postButton];
    
    self.postLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd/4, ht, wd/2, 20)];
    self.postLabel.text = @"Post";
    self.postLabel.textColor = [UIColor whiteColor];
    self.postLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.postLabel];
    
    self.interestButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-60, 60, 60)];
    [self.interestButton setImage:[UIImage imageNamed:@"addgroup"] forState:UIControlStateNormal];
    [self.interestButton addTarget:self action:@selector(interestButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.interestButton];
    
    self.interestLabel = [[UILabel alloc] initWithFrame:CGRectMake(wd/4, ht, wd/2, 20)];
    self.interestLabel.text = @"Interest";
    self.interestLabel.textColor = [UIColor whiteColor];
    self.interestLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.interestLabel];
    
    UIView *closeButtonContainer = [[UIView alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-60, 60, 60)];
    closeButtonContainer.backgroundColor = [UIColor whiteColor];
    closeButtonContainer.layer.cornerRadius = 30.0;
    [closeButtonContainer.layer setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.25] CGColor]];
    [closeButtonContainer.layer setBorderWidth:1.0];
    [self addSubview:closeButtonContainer];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 25, ht-55, 50, 50)];
    [self.closeButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.eventButton.frame = CGRectMake(wd / 4 - 30, ht - 160, 60, 60);
                         self.postButton.frame = CGRectMake(wd / 2 - 30, ht - 200, 60, 60);
                         self.interestButton.frame = CGRectMake((wd * 3) / 4 - 30, ht - 160, 60, 60);
                         self.eventLabel.frame = CGRectMake(0, ht - 95, wd/2, 20);
                         self.postLabel.frame = CGRectMake(wd/4, ht - 135, wd/2, 20);
                         self.interestLabel.frame = CGRectMake(wd/2, ht - 95, wd/2, 20);
                         self.closeButton.transform = CGAffineTransformRotate(self.closeButton.transform, M_PI * (-0.75));
                     }
                     completion: ^(BOOL finished) {
                         
                     }];

}

-(void)eventButtonClick:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        [self removeFromSuperview];
        return;
    }
    
    MFCreateView *createView = [[MFCreateView alloc] init];
    [MFHelpers open:createView onView:self.superview];
    [MFHelpers close:self];
}

-(void)postButtonClick:(id)sender {
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        [self removeFromSuperview];
        return;
    }
    
    MFCreatePostView *createPostView = [[MFCreatePostView alloc] init];
    [MFHelpers open:createPostView onView:self.superview];
    [MFHelpers close:self];
}

-(void)interestButtonClick:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        [self removeFromSuperview];
        return;
    }
    
    MFCreateGroupView *createGroupView = [[MFCreateGroupView alloc] init];
    [MFHelpers open:createGroupView onView:self.superview];
    [MFHelpers close:self];
}

-(void)closeButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         self.eventButton.frame = CGRectMake((wd / 2) - 30, ht-60, 60, 60);
                         self.postButton.frame = CGRectMake((wd / 2) - 30, ht-60, 60, 60);
                         self.interestButton.frame = CGRectMake((wd / 2) - 30, ht-60, 60, 60);
                         self.eventLabel.frame = CGRectMake(wd/4, ht, wd/2, 20);
                         self.postLabel.frame = CGRectMake(wd/4, ht, wd/2, 20);
                         self.interestLabel.frame = CGRectMake(wd/4, ht, wd/2, 20);
                         self.closeButton.transform = CGAffineTransformRotate(self.closeButton.transform, M_PI * (0.75));
                     }
                     completion: ^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
}

-(void)nothing:(id)sender {
    
}
                            
                            
@end
