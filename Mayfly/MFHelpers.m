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

+(NSString *)dateDiffByDate:(NSDate *)date
{
    NSString *dateDiff = @"";
    if(![date isMemberOfClass:[NSNull class]])
    {
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:date];
        dateDiff = [self dateDiff:secondsBetween];
    }
    return dateDiff;
}

+(NSString *)dateDiffBySeconds:(NSInteger)seconds
{
    NSTimeInterval secondsBetween = (double)seconds;
    return [self dateDiff:secondsBetween];
}

+(NSString *)dateDiff:(NSTimeInterval)secondsBetween
{
    NSString *dateDiff = @"";
    if(secondsBetween > 600000)
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM d h:mm a"];
        NSDate *date = [[NSDate date] dateByAddingTimeInterval: (-1 * secondsBetween)];
        
        return [format stringFromDate:date];
    }
    else if(secondsBetween > 86400)
    {
        int value = (int)secondsBetween / 86400;
        if(value == 1)
            dateDiff = @"1 day ago";
        else
            dateDiff = [NSString stringWithFormat:@"%d days ago", value];
    }
    else if(secondsBetween > 3600)
    {
        int value = (int)secondsBetween / 3600;
        if(value == 1)
            dateDiff = @"1 hour ago";
        else
            dateDiff = [NSString stringWithFormat:@"%d hours ago", value];
    }
    else if(secondsBetween > 60)
    {
        int value = ((int)secondsBetween / 60);
        if(value == 1)
            dateDiff = @"1 minute ago";
        else
            dateDiff = [NSString stringWithFormat:@"%d minutes ago", value];
    }
    else
        dateDiff = @"Now";

    return dateDiff;
}



@end
