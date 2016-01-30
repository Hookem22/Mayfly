//
//  MFRightSideView.m
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFNotificationView.h"

@interface MFNotificationView ()

@property (nonatomic, strong) UIScrollView *notificationsView;
@property (nonatomic, strong) NSArray *notifications;

@end

@implementation MFNotificationView

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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer1];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelButtonClick:)];
    [self addGestureRecognizer:singleTap];
    
    UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake((wd * 3) / 4, 0, wd / 4, ht - 60)];
    [closeView addGestureRecognizer:singleTap];
    [self addSubview:closeView];
    
    self.notificationsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (wd * 3) / 4, ht - 60)];
    self.notificationsView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:57.0/255.0 blue:74.0/255.0 alpha:1.0];
    [self addSubview:self.notificationsView];
    
    //[self loadNotifications];
}

-(void)loadNotifications
{
    for(UIView *subview in self.notificationsView.subviews)
        [subview removeFromSuperview];
    
    [MFHelpers showProgressView:self];
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    wd = (wd * 3) / 4;
    int viewY = 0;
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    
    //Add Groups
    UIView *grouTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 40)];
    grouTitleView.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:74.0/255.0 blue:94.0/255.0 alpha:1.0];
    [self.notificationsView addSubview:grouTitleView];
    viewY += 10;
    
    UILabel *groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, viewY, wd, 20)];
    groupTitleLabel.text = @"MY INTERESTS";
    groupTitleLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [groupTitleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [self.notificationsView addSubview:groupTitleLabel];
    viewY += 30;
    
    for(int i = 0; i < currentUser.groups.count; i++) {
        Group *group = currentUser.groups[i];
        
        UIControl *groupView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 40)];
        [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
        groupView.tag = i;
        
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
        groupLabel.text = [NSString stringWithFormat:@"%@", group.name];
        groupLabel.textColor = [UIColor whiteColor];
        [groupLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [groupView addSubview:groupLabel];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, groupView.frame.size.height - 1.0f, groupView.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:63.0/255.0 green:69.0/255.0 blue:82.0/255.0 alpha:1.0];
        [groupView addSubview:bottomBorder];
        
        [self.notificationsView addSubview:groupView];
        viewY += 40;
    }
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 40)];
    titleView.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:74.0/255.0 blue:94.0/255.0 alpha:1.0];
    [self.notificationsView addSubview:titleView];
    viewY += 10;
                         
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, viewY, wd, 20)];
    titleLabel.text = @"NOTIFICATIONS";
    titleLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [self.notificationsView addSubview:titleLabel];
    viewY += 30;
    
    [Notification get:currentUser.userId completion:^(NSArray *notifications)
     {
         int newViewY = viewY;
         self.notifications = notifications;
         for(int i = 0; i < [notifications count]; i++)
         {
             Notification *notification = (Notification *)[notifications objectAtIndex:i];
             
             UIControl *notificationView = [[UIControl alloc] initWithFrame:CGRectMake(0, newViewY, wd, 60)];
             [notificationView addTarget:self action:@selector(notificationClicked:) forControlEvents:UIControlEventTouchUpInside];
             notificationView.tag = i;
             
             UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
             messageLabel.text = [NSString stringWithFormat:@"%@", notification.message];
             messageLabel.textColor = [UIColor whiteColor];
             [messageLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [notificationView addSubview:messageLabel];
             
             UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, wd, 20)];
             timeLabel.text = [MFHelpers dateDiffBySeconds:notification.secondsSince];
             [timeLabel setFont:[UIFont systemFontOfSize:16]];
             timeLabel.textColor = [UIColor whiteColor];
             [notificationView addSubview:timeLabel];
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, notificationView.frame.size.height - 1.0f, notificationView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:63.0/255.0 green:69.0/255.0 blue:82.0/255.0 alpha:1.0];
             [notificationView addSubview:bottomBorder];
             
             [self.notificationsView addSubview:notificationView];
             newViewY += 60;
         }
         
         self.notificationsView.contentSize = CGSizeMake(wd, newViewY + 70);
         [MFHelpers hideProgressView:self];
     }];
}

-(void)groupClicked:(id)sender
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    
    UIButton *button = (UIButton *)sender;
    Group *group = currentUser.groups[button.tag];
    
    MFGroupDetailView *groupView = [[MFGroupDetailView alloc] init:group];
    [MFHelpers openFromRight:groupView onView:self.superview];
    
    [self cancelButtonClick:self];
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
        
    [self cancelButtonClick:self];
}

-(void)cancelButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFEventsView *eventsView;
    for(UIView *subview in self.superview.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
                         eventsView.frame = CGRectMake(0, 60, wd, ht - 60);
                     }
                     completion:^(BOOL finished){

                     }];
    
}

-(void)nothing:(id)sender {
    
}


@end
