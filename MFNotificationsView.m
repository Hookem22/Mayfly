//
//  MFNotificationsView.m
//  Pow Wow
//
//  Created by Will Parks on 2/18/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFNotificationsView.h"

@interface MFNotificationsView ()

@property (nonatomic, strong) NSArray *notifications;

@end

@implementation MFNotificationsView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0];

        self.notifications = [[NSMutableArray alloc] init];
        
        UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
        [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:recognizer1];
    }
    return self;
}

-(void)loadNotifications
{
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];

    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIView *notificationsLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 40)];
    notificationsLabelView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self addSubview:notificationsLabelView];
    
    UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, wd - 25, 30)];
    notificationsLabel.text = @"Notifications";
    notificationsLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
    notificationsLabel.font = [UIFont boldSystemFontOfSize:18];
    notificationsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:notificationsLabel];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    [Notification get:currentUser.userId completion:^(NSArray *notifications)
     {
         int viewY = 35;
         self.notifications = notifications;
         for(int i = 0; i < [notifications count]; i++)
         {
             Notification *notification = (Notification *)[notifications objectAtIndex:i];

             UIControl *notificationView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 50)];
             [notificationView addTarget:self action:@selector(notificationClicked:) forControlEvents:UIControlEventTouchUpInside];
             notificationView.tag = i;
             
             UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, wd - 30, 20)];
             messageLabel.text = [NSString stringWithFormat:@"%@", notification.message];
             [messageLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [notificationView addSubview:messageLabel];

             UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 26, wd - 30, 20)];
             [timeLabel setText:[MFHelpers dateDiffBySeconds:notification.secondsSince]];
             timeLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
             [timeLabel setFont:[UIFont boldSystemFontOfSize:12]];
             [notificationView addSubview:timeLabel];

             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(10, notificationView.frame.size.height - 1.0f, notificationView.frame.size.width - 25, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
             [notificationView addSubview:bottomBorder];

             [self addSubview:notificationView];
             viewY += 50;
         }

         self.contentSize = CGSizeMake(wd, viewY + 70);
     }];
}

-(void)notificationClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    Notification *notification = (Notification *)[self.notifications objectAtIndex:button.tag];

    NSArray *currentEvents = (NSArray *)[Session sessionVariables][@"currentEvents"];
    Event *event;
    for(Event *e in currentEvents) {
        if([e.eventId isEqualToString:notification.eventId]){
            event = e;
            break;
        }
    }

    if(event == nil || [event.eventId isEqualToString:@""])
    {
        [Event get:notification.eventId completion:^(Event *e) {
            MFDetailView *detailView = [[MFDetailView alloc] init:e];
            [MFHelpers openFromRight:detailView onView:self.superview];
        }];
    }
    else {
        MFDetailView *detailView = [[MFDetailView alloc] init:event];
        [MFHelpers openFromRight:detailView onView:self.superview];
    }
}

-(void)nothing:(id)sender {
    
}

@end
