//
//  MFRightSideView.m
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFRightSideView.h"

@interface MFRightSideView ()

@property (nonatomic, strong) UIScrollView *notificationsView;
@property (nonatomic, strong) NSArray *notifications;

@end

@implementation MFRightSideView

-(id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    self.notificationsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (wd * 3) / 4, ht - 60)];
    [self addSubview:self.notificationsView];
    
    [self loadNotifications];
}

-(void)loadNotifications
{
    for(UIView *subview in self.notificationsView.subviews)
        [subview removeFromSuperview];
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    wd = (wd * 3) / 4;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [Notification get:appDelegate.facebookId completion:^(NSArray *notifications)
     {
         self.notifications = notifications;
         for(int i = 0; i < [notifications count]; i++)
         {
             Notification *notification = (Notification *)[notifications objectAtIndex:i];
             
             UIControl *notificationView = [[UIControl alloc] initWithFrame:CGRectMake(0, (i * 60), wd, 60)];
             [notificationView addTarget:self action:@selector(notificationClicked:) forControlEvents:UIControlEventTouchUpInside];
             notificationView.tag = i;
             
             UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
             messageLabel.text = [NSString stringWithFormat:@"%@", notification.message];
             [messageLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [notificationView addSubview:messageLabel];
             
             UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, wd, 20)];
             timeLabel.text = [MFHelpers dateDiff:notification.createdDate];
             [timeLabel setFont:[UIFont boldSystemFontOfSize:12]];
             [notificationView addSubview:timeLabel];
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, notificationView.frame.size.height - 1.0f, notificationView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
             [notificationView addSubview:bottomBorder];
             
             [self.notificationsView addSubview:notificationView];
             self.notificationsView.contentSize = CGSizeMake(self.notificationsView.frame.size.width, (i + 1) * 60 + 10);
         }
     }];
}

-(void)notificationClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    Notification *notification = (Notification *)[self.notifications objectAtIndex:button.tag];
    
    [Event get:notification.eventId completion:^(Event *event)
    {
        MFDetailView *detailView = [[MFDetailView alloc] init:event];
        [MFHelpers open:detailView onView:self.superview];
        
        [self cancelButtonClick:self];
    }];
    

}

-(void)cancelButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(wd, 60, (wd * 3) / 4, ht - 60);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

@end
