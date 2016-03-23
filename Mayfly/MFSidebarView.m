//
//  MFRightSideView.m
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFSidebarView.h"

@interface MFSidebarView ()

//@property (nonatomic, strong) UIScrollView *notificationsView;
//@property (nonatomic, strong) NSArray *notifications;

@property (nonatomic, strong) UIButton *postsButton;
@property (nonatomic, strong) UIButton *eventsButton;
@property (nonatomic, strong) UIButton *interestsButton;
@property (nonatomic, strong) UIButton *notificationsButton;
@property (nonatomic, strong) UILabel *pointsLabel;

@end

@implementation MFSidebarView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.75];
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
    
    wd = (wd * 3) / 4;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, ht - 60)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 140)];
    [view addSubview:userView];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(10, 15, 80, 80) facebookId:currentUser.facebookId];
    [userView addSubview:pic];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 80, 20)];
    [nameLabel setText:currentUser.firstName];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [userView addSubview:nameLabel];
    
    self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, wd - 70, 20)];
    self.pointsLabel.text = @"0";
    self.pointsLabel.textAlignment = NSTextAlignmentRight;
    [self.pointsLabel setFont:[UIFont systemFontOfSize:24.0]];
    [userView addSubview:self.pointsLabel];
    
    UIImageView *litImage = [[UIImageView alloc] initWithFrame:CGRectMake(wd - 85, 15, 80, 80)];
    [litImage setImage:[UIImage imageNamed:@"match"]];
    [userView addSubview:litImage];
    
    UIButton *questionButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 25, 5, 20, 20)];
    [questionButton setImage:[UIImage imageNamed:@"questionmark"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:questionButton];
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, userView.frame.size.height - 1, wd, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:borderView];
    
    UIButton *eventsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 140, wd, 60)];
    [eventsButton setTitle:@"Events" forState:UIControlStateNormal];
    [eventsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [eventsButton addTarget:self action:@selector(eventsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.eventsButton = eventsButton;
    [view addSubview:eventsButton];
    
    UIView *eventsBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, eventsButton.frame.origin.y + eventsButton.frame.size.height - 1, wd, 1)];
    eventsBorderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:eventsBorderView];
    
    UIButton *postsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, wd, 60)];
    [postsButton setTitle:@"Posts" forState:UIControlStateNormal];
    [postsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [postsButton addTarget:self action:@selector(postsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [postsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    self.postsButton = postsButton;
    [view addSubview:postsButton];
    
    UIView *postsBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, postsButton.frame.origin.y + postsButton.frame.size.height - 1, wd, 1)];
    postsBorderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:postsBorderView];
    
    UIButton *interestsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 260, wd, 60)];
    [interestsButton setTitle:@"Interests" forState:UIControlStateNormal];
    [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [interestsButton addTarget:self action:@selector(interestsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [interestsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    self.interestsButton = interestsButton;
    [view addSubview:interestsButton];
    
    UIView *interestsBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, interestsButton.frame.origin.y + interestsButton.frame.size.height - 1, wd, 1)];
    interestsBorderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:interestsBorderView];
    
    UIButton *notificationsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 320, wd, 60)];
    [notificationsButton setTitle:@"Notifications" forState:UIControlStateNormal];
    [notificationsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [notificationsButton addTarget:self action:@selector(notificationsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [notificationsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    self.notificationsButton = notificationsButton;
    [view addSubview:notificationsButton];
    
    UIView *notificationsBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, notificationsButton.frame.origin.y + notificationsButton.frame.size.height - 1, wd, 1)];
    notificationsBorderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:notificationsBorderView];
    
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, ht - 100, wd, 40)];
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    [settingsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [view addSubview:settingsButton];
    
    UIView *settingsBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, settingsButton.frame.origin.y, wd, 1)];
    settingsBorderView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [view addSubview:settingsBorderView];
    
//    self.notificationsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (wd * 3) / 4, ht - 60)];
//    self.notificationsView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:57.0/255.0 blue:74.0/255.0 alpha:1.0];
//    [self addSubview:self.notificationsView];
    
    //[self loadNotifications];
}

-(void)loadUserPoints {
    if([self.pointsLabel.text isEqualToString:@"0"]) {
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        [currentUser getPoints:^(int points) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            self.pointsLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:points]];
        }];
    }
}

-(void)postsButtonClick:(id)sender
{
    [self.postsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.eventsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.interestsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.notificationsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self cancelButtonClick:sender];
    
    if([self.superview isMemberOfClass:[MFView class]]) {
        MFView *mfView = (MFView *)self.superview;
        [mfView postsButtonClick];
    }
}

-(void)eventsButtonClick:(id)sender
{
    [self.postsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.interestsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.notificationsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self cancelButtonClick:sender];
    
    if([self.superview isMemberOfClass:[MFView class]]) {
        MFView *mfView = (MFView *)self.superview;
        [mfView eventsButtonClick];
    }
}

-(void)interestsButtonClick:(id)sender
{
    [self.postsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.eventsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.interestsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self.notificationsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self cancelButtonClick:sender];
    
    if([self.superview isMemberOfClass:[MFView class]]) {
        MFView *mfView = (MFView *)self.superview;
        [mfView interestsButtonClick];
    }
}

-(void)notificationsButtonClick:(id)sender
{
    [self.postsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.eventsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.interestsButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.notificationsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [self cancelButtonClick:sender];
    
    if([self.superview isMemberOfClass:[MFView class]]) {
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
        
        MFView *mfView = (MFView *)self.superview;
        for(UIView *subview in mfView.subviews) {
            if([subview isMemberOfClass:[MFNotificationsView class]]) {
                MFNotificationsView *notificationsView = (MFNotificationsView *)subview;
                [notificationsView loadNotifications];
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     notificationsView.frame = CGRectMake(0, 60, wd, ht - 60);
                                 }
                                 completion:^(BOOL finished){ }];
            }
        }
    }
}

-(void)settingsButtonClick:(id)sender {
    MFSettingsView *settingsView = [[MFSettingsView alloc] init];
    [self.superview addSubview:settingsView];
    [self cancelButtonClick:sender];
}

-(void)questionButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lit Points"
                                                    message:@"Create events to get points. The more people that join your event, the more points you get!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)cancelButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFPostsView *postsView;
    MFEventsView *eventsView;
    MFGroupView *groupView;
    MFNotificationsView *notificationsView;
    for(UIView *subview in self.superview.subviews)
    {
        if([subview isMemberOfClass:[MFPostsView class]])
            postsView = (MFPostsView *)subview;
        else if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
        else if([subview isMemberOfClass:[MFGroupView class]])
            groupView = (MFGroupView *)subview;
        else if([subview isMemberOfClass:[MFNotificationsView class]])
            notificationsView = (MFNotificationsView *)subview;
    }
    MFView *mfView = (MFView *)self.superview;
    
    self.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.0];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
                         mfView.addView.frame = CGRectMake(0, ht - 60, wd, 60);
                         
                         if(postsView.frame.origin.x < wd) {
                             postsView.frame = CGRectMake(0, 60, wd, ht - 60);
                         }
                         if(eventsView.frame.origin.x < wd) {
                             eventsView.frame = CGRectMake(0, 60, wd, ht - 60);
                         }
                         if(groupView.frame.origin.x < wd) {
                             groupView.frame = CGRectMake(0, 60, wd, ht - 60);
                         }
                         if(notificationsView.frame.origin.x < wd) {
                             notificationsView.frame = CGRectMake(0, 60, wd, ht - 60);
                         }
                     }
                     completion:^(BOOL finished){
                         self.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.75];
                     }];
    
}

-(void)nothing:(id)sender {
    
}


@end
