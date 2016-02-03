//
//  MFInstructionsView.m
//  Pow Wow
//
//  Created by Will Parks on 2/1/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFInstructionsView.h"

@interface MFInstructionsView()

@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;
@property (nonatomic, strong) UIView *view3;
@property (nonatomic, strong) UIImageView *circles;
@property (nonatomic, strong) UIButton *button;

@end

@implementation MFInstructionsView

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
    
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClick:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer1];
    
    [MFHelpers addTitleBar:self titleText:@""];
    
    UIImageView *titlePic = [[UIImageView alloc] initWithFrame:CGRectMake(90, 25, wd - 180, 30)];
    [titlePic setImage:[UIImage imageNamed:@"title"]];
    [self addSubview:titlePic];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 80, wd, ht - 100)];
    self.view1 = view1;
    [self addSubview:view1];
    
    UILabel *text1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 22)];
    text1.text = @"Find and join activities";
    [text1 setFont:[UIFont systemFontOfSize:20]];
    text1.textAlignment = NSTextAlignmentCenter;
    [view1 addSubview:text1];
    
    UILabel *text2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, wd, 22)];
    text2.text = @"at St. Edward's";
    [text2 setFont:[UIFont systemFontOfSize:20]];
    text2.textAlignment = NSTextAlignmentCenter;
    [view1 addSubview:text2];
    
    UIImageView *appPic1 = [[UIImageView alloc] initWithFrame:CGRectMake(75, 60, wd - 150, ht - 230)];
    [appPic1 setImage:[UIImage imageNamed:@"appScreenshot"]];
    [view1 addSubview:appPic1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(wd, 80, wd, ht - 100)];
    self.view2 = view2;
    [self addSubview:view2];
    
    UILabel *text3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 22)];
    text3.text = @"Create your own activites";
    [text3 setFont:[UIFont systemFontOfSize:20]];
    text3.textAlignment = NSTextAlignmentCenter;
    [view2 addSubview:text3];
    
    UILabel *text4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, wd, 22)];
    text4.text = @"and invite your friends";
    [text4 setFont:[UIFont systemFontOfSize:20]];
    text4.textAlignment = NSTextAlignmentCenter;
    [view2 addSubview:text4];
    
    UIImageView *appPic2 = [[UIImageView alloc] initWithFrame:CGRectMake(75, 60, wd - 150, ht - 230)];
    [appPic2 setImage:[UIImage imageNamed:@"appScreenshot3"]];
    [view2 addSubview:appPic2];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(wd, 80, wd, ht - 100)];
    self.view3 = view3;
    [self addSubview:view3];
    
    UILabel *text5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 22)];
    text5.text = @"Add interests to hear";
    [text5 setFont:[UIFont systemFontOfSize:20]];
    text5.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:text5];
    
    UILabel *text6 = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, wd, 22)];
    text6.text = @"when they post new events";
    [text6 setFont:[UIFont systemFontOfSize:20]];
    text6.textAlignment = NSTextAlignmentCenter;
    [view3 addSubview:text6];
    
    UIImageView *appPic3 = [[UIImageView alloc] initWithFrame:CGRectMake(75, 60, wd - 150, ht - 230)];
    [appPic3 setImage:[UIImage imageNamed:@"appScreenshot2"]];
    [view3 addSubview:appPic3];
    
    UIImageView *circles = [[UIImageView alloc] initWithFrame:CGRectMake((wd / 2) - 27, ht - 84, 54, 14)];
    [circles setImage:[UIImage imageNamed:@"circles1"]];
    self.circles = circles;
    [self addSubview:circles];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, ht - 60, wd - 100, 40);
    [button setTitle:@"Ok, cool" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button.layer setBorderColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor];
    [button.layer setBorderWidth:1.0];
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:20.f];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.button = button;
    [self addSubview:button];
}

-(void)buttonClick:(id)sender {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UIButton *button = self.button;
    if([button.titleLabel.text isEqualToString:@"Ok, cool"]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view1.frame = CGRectMake((int)(-1 * wd), 80, wd, 22);
                             self.view2.frame = CGRectMake(0, 80, wd, 22);
                         }
                         completion:^(BOOL finished){
                             [self.circles setImage:[UIImage imageNamed:@"circles2"]];
                             [button setTitle:@"Alright, next" forState:UIControlStateNormal];
                         }];
    }
    else if([button.titleLabel.text isEqualToString:@"Alright, next"]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view2.frame = CGRectMake((int)(-1 * wd), 80, wd, 22);
                             self.view3.frame = CGRectMake(0, 80, wd, 22);
                         }
                         completion:^(BOOL finished){
                             [self.circles setImage:[UIImage imageNamed:@"circles3"]];
                             [button setTitle:@"Got it, let's go" forState:UIControlStateNormal];
                         }];
    }
    else {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.frame = CGRectMake((int)(-1 * wd), 0, wd, ht);
                         }
                         completion:^(BOOL finished){
                             [self removeFromSuperview];
                         }];
    }
}


-(void)backSwipe:(id)sender {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIButton *button = self.button;
    if([button.titleLabel.text isEqualToString:@"Alright, next"]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view1.frame = CGRectMake(0, 80, wd, 22);
                             self.view2.frame = CGRectMake(wd, 80, wd, 22);
                         }
                         completion:^(BOOL finished){
                             [self.circles setImage:[UIImage imageNamed:@"circles1"]];
                             [button setTitle:@"Ok, cool" forState:UIControlStateNormal];
                         }];
    }
    else if([button.titleLabel.text isEqualToString:@"Got it, let's go"]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.view2.frame = CGRectMake(0, 80, wd, 22);
                             self.view3.frame = CGRectMake(wd, 80, wd, 22);
                         }
                         completion:^(BOOL finished){
                             [self.circles setImage:[UIImage imageNamed:@"circles2"]];
                             [button setTitle:@"Alright, next" forState:UIControlStateNormal];
                         }];
    }
}

@end
