//
//  MFHelpers.m
//  Mayfly
//
//  Created by Will Parks on 6/12/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFHelpers.h"

@implementation MFHelpers


+(void)showProgressView:(UIView *)view
{
    [view addSubview:[[MFProgressView alloc] init]];
}
+(void)hideProgressView:(UIView *)view
{
    for(UIView *subview in view.subviews)
    {
        if([subview isMemberOfClass:[MFProgressView class]])
            [subview removeFromSuperview];
    }
}

+(void)open:(UIView *)view onView:(UIView *)onView
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    view.frame = CGRectMake(0, ht, wd, ht);
    [onView addSubview:view];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

+(void)openFromRight:(UIView *)view onView:(UIView *)onView
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    view.frame = CGRectMake(wd, 0, wd, ht);
    [onView addSubview:view];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){

                     }];
}

+(void)close:(UIView *)view
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, ht, wd, ht - 60);
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

+(void)closeRight:(UIView *)view
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(wd, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}
+(void)remove:(UIView *)view
{
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, ht, view.frame.size.width, view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

@end
