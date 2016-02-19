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
    
    [UIView animateWithDuration:0.0
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
        dateDiff = @"Just Now";

    return dateDiff;
}

+(void)addTitleBar:(UIView *)view titleText:(NSString *)titleText
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 60, wd, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0];
    bottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
    bottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    bottomBorder.layer.shadowRadius = 3.0f;
    bottomBorder.layer.shadowOpacity = 1.0f;
    [view addSubview:bottomBorder];
    
    UIView *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 60)];
    headerView.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0];
    [view addSubview:headerView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, wd - 90, 60)];
    headerLabel.text = titleText;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    [view addSubview:headerLabel];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:headerLabel.font, NSFontAttributeName, nil];
    int titleWidth = [[[NSAttributedString alloc] initWithString:headerLabel.text attributes:attributes] size].width;
    if(titleWidth > wd - 90)
        headerLabel.frame = CGRectMake(45, 10, wd - 70, 60);
}

+(CGFloat)heightForText:(UITextView *)textView width:(NSUInteger)width
{
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: textView.font}
                                               context:nil];
    rect.size.width = ceil(rect.size.width);
    rect.size.height = ceil(rect.size.height);
    return rect.size.height;
}

+(void)GetBranchUrl:(NSUInteger)referenceId eventName:(NSString *)eventName completion:(QSCompletionBlock)completion
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSDictionary *params = @{@"ReferenceName": currentUser.firstName,
                             @"ReferenceId": [NSString stringWithFormat:@"%lu", (unsigned long)referenceId]};
    // ... insert code to start the spinner of your choice here ...
    [[Branch getInstance] getShortURLWithParams:params
                                     andChannel:@"SMS"
                                     andFeature:@"Referral"
                                    andCallback:^(NSString *url, NSError *error) {
                                        if(!error) {
                                            NSString *message = [NSString stringWithFormat:@"You're invited to %@. Download the app: %@", eventName, url];
                                            completion(message);
                                     }
                                     else {
                                        NSLog(@"%@", error);
                                     }
                                        
                                        /*if (!error) {
                                            // Check to make sure we can send messages on this device
                                            if ([MFMessageComposeViewController canSendText]) {
                                             
                                                 MFMessageComposeViewController *messageComposer =
                                                 [[MFMessageComposeViewController alloc] init];
                                                 // Set the contents of the SMS/iMessage -- be sure to include the URL!
                                                 [messageComposer setBody:[NSString stringWithFormat:
                                                 @"Check out MyApp -- use my link to get free  points: %@", url]];
                                                 messageComposer.messageComposeDelegate = self;
                                             
                                                ViewController *vc = (ViewController *)self.window.rootViewController;
                                                [vc sendTextMessage:phoneNumbers message:url];
                                                
                                            } else {
                                                // ... insert code to stop the spinner here
                                                [[[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                            message:@"Your device cannot send messages."
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Okay"
                                                                  otherButtonTitles:nil] show];
                                            }
                                        }*/
                                    }];
}



@end
