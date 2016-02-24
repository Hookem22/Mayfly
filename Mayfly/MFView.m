//
//  MFView.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFView.h"
#import "ViewController.h"

@interface MFView ()

//@property (nonatomic, strong) UIButton *groupButton;
//@property (nonatomic, strong) UIButton *notificationButton;
//@property (nonatomic, strong) UIWebView *webView;

@end

@implementation MFView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    MFEventsView *eventsView = [[MFEventsView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    //[eventsView loadEvents];
    [self addSubview:eventsView];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.eventId.length > 0) {
        [eventsView goToEvent:appDelegate.eventId];
        [MFHelpers hideProgressView:self.superview];
        appDelegate.eventId = @"";
    }
    
    MFGroupView *groupView = [[MFGroupView alloc] init];
    groupView.frame = CGRectMake(wd, 60, wd, ht - 60);
    [groupView loadGroups];
    [self addSubview:groupView];
    
    [self addAddView];
    
    MFNotificationsView *notificationsView = [[MFNotificationsView alloc] init];
    notificationsView.frame = CGRectMake(wd, 60, wd, ht - 60);
    [self addSubview:notificationsView];
    
    [MFHelpers addTitleBar:self titleText:@""];
    
    UIButton *stEdsButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 63, 25, 127, 30)];
    [stEdsButton setImage:[UIImage imageNamed:@"powwowtitle"] forState:UIControlStateNormal];
    [stEdsButton addTarget:self action:@selector(addInstructions) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:stEdsButton];
    
//    UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 50, 25, 36, 36)];
//    [groupButton setImage:[UIImage imageNamed:@"whitegroup"] forState:UIControlStateNormal];
//    [groupButton addTarget:self action:@selector(groupButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:groupButton];
    
//    UISwipeGestureRecognizer *groupRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(groupButtonClick:)];
//    [groupRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self addGestureRecognizer:groupRecognizer];
    
    MFSidebarView *sidebarView = [[MFSidebarView alloc] init];
    sidebarView.frame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
    [self addSubview:sidebarView];
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 28, 25, 25)];
    [menuButton setImage:[UIImage imageNamed:@"smallmenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuButton];
    
    UISwipeGestureRecognizer *menuRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(menuButtonClick:)];
    [menuRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:menuRecognizer];
    
    [MFHelpers showProgressView:self];
    

    if(![FBSDKAccessToken currentAccessToken])
    {
        [self addInstructions];
    }
    
    /*
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
    */
    
    /*
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 60, 200, 40)];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    //loginButton.center = self.center;
    [self addSubview:loginButton];
    */
}

-(void)refreshEvents
{
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]])
        {
            MFEventsView *eventsView = (MFEventsView *)subview;
            [eventsView loadEvents];
        }
        else if([subview isMemberOfClass:[MFSidebarView class]])
        {
            MFSidebarView *sidebarView = (MFSidebarView *)subview;
            [sidebarView setup];
        }
    }
}


-(void) addButtonClick:(id)sender
{
    MFAddButtonView *addButtonView = [[MFAddButtonView alloc] init];
    [MFHelpers open:addButtonView onView:self];  
}

//-(void)groupButtonClick:(id)sender
//{
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//    
//    MFNotificationView *notificationView;
//    MFGroupView *groupView;
//    MFEventsView *eventsView;
//    for(UIView *subview in self.subviews)
//    {
//        if([subview isMemberOfClass:[MFNotificationView class]])
//            notificationView = (MFNotificationView *)subview;
//        else if([subview isMemberOfClass:[MFGroupView class]])
//            groupView = (MFGroupView *)subview;
//        else if([subview isMemberOfClass:[MFEventsView class]])
//            eventsView = (MFEventsView *)subview;
//    }
//    
//    CGRect notificationFrame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
//    CGRect groupFrame = CGRectMake(wd, 60, wd, ht- 60);
//    CGRect eventFrame = CGRectMake(0, 60, wd, ht - 60);
//    if(groupView.frame.origin.x > 0) {
//        groupFrame = CGRectMake(0, 60, wd, ht- 60);
//        eventFrame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
//    }
//    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         notificationView.frame = notificationFrame;
//                         groupView.frame = groupFrame;
//                         eventsView.frame = eventFrame;
//                     }
//                     completion:^(BOOL finished){
//                         for(UIView *subview in self.filterButtonsView.subviews){
//                             if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
//                                 School *school = (School *)[Session sessionVariables][@"currentSchool"];
//                                 UIButton *all = (UIButton *)subview;
//                                 [all setTitle:[NSString stringWithFormat:@"%@", [school.name uppercaseString]] forState:UIControlStateNormal];
//                             }
//                             else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
//                                 UIButton *mine = (UIButton *)subview;
//                                 [mine setTitle:@"MY INTERESTS" forState:UIControlStateNormal];
//                             }
//                         }
//                         for(UIView *subview in self.addView.subviews){
//                             if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
//                                 UIButton *eventsButton = (UIButton *)subview;
//                                 [eventsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                 [eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//                             }
//                             else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
//                                 UIButton *interestsButton = (UIButton *)subview;
//                                 [interestsButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                 [interestsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//                             }
//                         }
//                     }];
//}

-(void)menuButtonClick:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self];
        return;
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFSidebarView *sidebarView;
    MFGroupView *groupView;
    MFEventsView *eventsView;
    MFNotificationsView *notificationsView;
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFSidebarView class]])
            sidebarView = (MFSidebarView *)subview;
        else if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
        else if([subview isMemberOfClass:[MFGroupView class]])
            groupView = (MFGroupView *)subview;
        else if([subview isMemberOfClass:[MFNotificationsView class]])
            notificationsView = (MFNotificationsView *)subview;
    }
    
    CGRect sidebarFrame = CGRectMake((int)(-1 * wd), 60, wd, ht- 60);
    CGRect eventFrame = CGRectMake(0, 60, wd, ht - 60);
    CGRect addFrame = CGRectMake(0, ht-60, wd, 60);
    if(sidebarView.frame.origin.x < 0) {
        //[notificationView loadNotifications];
        sidebarFrame = CGRectMake(0, 60, wd, ht- 60);
        eventFrame = CGRectMake((wd * 3) / 4, 60, wd, ht - 60);
        addFrame = CGRectMake((wd * 3) / 4, ht-60, wd, 60);
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         sidebarView.frame = sidebarFrame;
                         eventsView.frame = eventFrame;
                         self.addView.frame = addFrame;
                         if(groupView.frame.origin.x < wd) {
                             groupView.frame = eventFrame;
                         }
                         if(notificationsView.frame.origin.x < wd) {
                             notificationsView.frame = eventFrame;
                         }
                     }
                     completion:^(BOOL finished){
                         [sidebarView loadUserPoints];
                     }];

}

-(void)addInstructions {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFInstructionsView *view = [[MFInstructionsView alloc] init];
    view.frame = CGRectMake(0, 0, wd, ht);
    [self addSubview:view];
}

//-(void)addFilterButtons
//{
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//
//    self.filterButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, wd, 40)];
//    [self addSubview:self.filterButtonsView];
//    
//    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 40, wd, 1)];
//    bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//    bottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
//    bottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    bottomBorder.layer.shadowRadius = 3.0f;
//    bottomBorder.layer.shadowOpacity = 1.0f;
//    [self.filterButtonsView addSubview:bottomBorder];
//    
//    UIButton *allEventsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, wd/2, 40)];
//    [allEventsButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
//    [allEventsButton addTarget:self action:@selector(allEventsClick:) forControlEvents:UIControlEventTouchUpInside];
//    [allEventsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [allEventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//    allEventsButton.backgroundColor = [UIColor whiteColor];
//    allEventsButton.tag = 0;
//    [self.filterButtonsView addSubview:allEventsButton];
//    
//    UIButton *myEventsButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/2, 0, wd/2, 40)];
//    [myEventsButton setTitle:@"MY EVENTS" forState:UIControlStateNormal];
//    [myEventsButton addTarget:self action:@selector(myEventsClick:) forControlEvents:UIControlEventTouchUpInside];
//    [myEventsButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [myEventsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//    myEventsButton.backgroundColor = [UIColor whiteColor];
//    myEventsButton.tag = 1;
//    [self.filterButtonsView addSubview:myEventsButton];
//    
//    UIView *selected = [[UIView alloc] initWithFrame:CGRectMake(0, 36, wd/2, 5)];
//    selected.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
//    [self.filterButtonsView addSubview:selected];
//}

-(void)addAddView
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, ht-60, wd, 60)];
    self.addView = addView;
    [self addSubview:addView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, wd, 40)];
    backgroundView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.75];
    [addView addSubview:backgroundView];
    
    UIButton *allButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, wd/2 -25, 40)];
    [allButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
    [allButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [allButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [allButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    allButton.tag = 0;
    [addView addSubview:allButton];
    
    UIButton *myButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/2 + 25, 20, wd/2 - 25, 40)];
    [myButton setTitle:@"MY EVENTS" forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [myButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [myButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    myButton.tag = 1;
    [addView addSubview:myButton];
    
    UIView *addButtonContainer = [[UIView alloc] initWithFrame:CGRectMake((wd / 2) - 30, 0, 60, 60)];
    addButtonContainer.backgroundColor = [UIColor whiteColor];
    addButtonContainer.layer.cornerRadius = 30.0;
    [addButtonContainer.layer setBorderColor:[[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.25] CGColor]];
    [addButtonContainer.layer setBorderWidth:1.0];
    [addView addSubview:addButtonContainer];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 25, 5, 50, 50)];
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:addButton];
}

-(void)filterButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self filter:(int)button.tag];
}

-(void)filter:(int)tagId {
    for(UIView *subview in self.addView.subviews){
        if([subview isMemberOfClass:[UIButton class]] && subview.tag == tagId) {
            UIButton *interestsButton = (UIButton *)subview;
            [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [interestsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        }
        if([subview isMemberOfClass:[UIButton class]] && subview.tag != tagId) {
            UIButton *eventsButton = (UIButton *)subview;
            [eventsButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [eventsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        }
    }
    
    MFGroupView *groupView;
    MFEventsView *eventsView;
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
        else if([subview isMemberOfClass:[MFGroupView class]])
            groupView = (MFGroupView *)subview;
    }
    if(groupView.frame.origin.x > 0) { //Events
        if(tagId == 0) {
            [eventsView populateAllEvents];
        }
        else if(tagId == 1) {
            [eventsView populateMyEvents];
        }
    }
    else { //Group
        if(tagId == 0) {
            [groupView populateAllInterests];
        }
        else if(tagId == 1) {
            [groupView populateMyInterests];
        }
    }
}

-(void)eventsButtonClick {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFGroupView class]]) {
            MFGroupView *groupView = (MFGroupView *)subview;
            groupView.frame = CGRectMake(wd, 60, wd, ht - 60);
        }
        if([subview isMemberOfClass:[MFNotificationsView class]]) {
            MFNotificationsView *notificationsView = (MFNotificationsView *)subview;
            notificationsView.frame = CGRectMake(wd, 60, wd, ht - 60);
        }
    }
    for(UIView *subview in self.addView.subviews)
    {
        if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
            UIButton *allButton = (UIButton *)subview;
            [allButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
        }
        else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
            UIButton *myButton = (UIButton *)subview;
            [myButton setTitle:@"MY EVENTS" forState:UIControlStateNormal];
        }
    }
    
    [self filter:0];
}

-(void)interestsButtonClick {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFGroupView class]]) {
            MFGroupView *groupView = (MFGroupView *)subview;
            [UIView animateWithDuration:0.3
                    animations:^{
                        groupView.frame = CGRectMake(0, 60, wd, ht - 60);
                    }
                    completion:^(BOOL finished){ }];
        }
        if([subview isMemberOfClass:[MFNotificationsView class]]) {
            MFNotificationsView *notificationsView = (MFNotificationsView *)subview;
            notificationsView.frame = CGRectMake(wd, 60, wd, ht - 60);
        }
    }
    for(UIView *subview in self.addView.subviews)
    {
        if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
            UIButton *allButton = (UIButton *)subview;
            [allButton setTitle:@"ST. EDWARD'S" forState:UIControlStateNormal];
        }
        else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
            UIButton *myButton = (UIButton *)subview;
            [myButton setTitle:@"MY INTERESTS" forState:UIControlStateNormal];
        }
    }

    [self filter:0];
}

-(void)goToEvent:(NSString *)eventId {
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]]) {
            MFEventsView *eventsView = (MFEventsView *)subview;
            [eventsView goToEvent:eventId];
        }
    }
}

//-(void)eventsButtonClick:(id)sender {
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//    
//    MFGroupView *groupView;
//    MFEventsView *eventsView;
//    for(UIView *subview in self.subviews)
//    {
//        if([subview isMemberOfClass:[MFEventsView class]])
//            eventsView = (MFEventsView *)subview;
//        else if([subview isMemberOfClass:[MFGroupView class]])
//            groupView = (MFGroupView *)subview;
//    }
//    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         groupView.frame = CGRectMake(wd, 60, wd, ht - 60);;
//                         eventsView.frame = CGRectMake(0, 60, wd, ht - 60);;
//                     }
//                     completion:^(BOOL finished){
//                         for(UIView *subview in self.filterButtonsView.subviews){
//                             if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
//                                 UIButton *all = (UIButton *)subview;
//                                 [all setTitle:@"UPCOMING" forState:UIControlStateNormal];
//                             }
//                             else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
//                                 UIButton *mine = (UIButton *)subview;
//                                 [mine setTitle:@"MY EVENTS" forState:UIControlStateNormal];
//                             }
//                         }
//                         for(UIView *subview in self.addView.subviews){
//                             if([subview isMemberOfClass:[UIButton class]] && subview.tag == 0) {
//                                 UIButton *eventsButton = (UIButton *)subview;
//                                 [eventsButton setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                 [eventsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//                             }
//                             else if([subview isMemberOfClass:[UIButton class]] && subview.tag == 1) {
//                                 UIButton *interestsButton = (UIButton *)subview;
//                                 [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//                                 [interestsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//                             }
//                         }
//                     }];
//    
//}


-(void)scrollDown {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.addView.frame = CGRectMake(0, ht, wd, 60);
                     }
                     completion:^(BOOL finished){ }];
}

-(void)scrollUp {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.addView.frame = CGRectMake(0, ht-60, wd, 60);
                     }
                     completion:^(BOOL finished){ }];
}

//////////////////////
///// Website ////////
//////////////////////

//-(void)loadWebsite
//{
//    NSUInteger referenceId = [[Session sessionVariables][@"referenceId"] integerValue];
//    if(referenceId > 0)
//    {
//        [self joinEvent:referenceId];
//        return;
//    }
//    
//    [MFHelpers showProgressView:self];
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//    
//    for(UIView *subview in self.subviews)
//    {
//        if(![subview isKindOfClass:[UIImageView class]])
//            [subview removeFromSuperview];
//    }
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
//    [self.webView setScalesPageToFit:YES];
//    self.webView.scrollView.bounces = NO;
//    self.webView.delegate = self;
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    double lat = location == NULL ? 0 : location.latitude;
//    double lng = location == NULL ? 0 : location.longitude;
//    
//    NSString *fbAccessToken = appDelegate.fbAccessToken == NULL ? @"" : appDelegate.fbAccessToken;
//    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&fbAccessToken=%@&deviceId=%@&pushDeviceToken=%@&lat=%f&lng=%f", fbAccessToken, uuid, uuid, lat, lng];
//    NSLog(@"%@", urlAddress);
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:requestObj];
//    
//    [self addSubview:self.webView];
//    [MFHelpers hideProgressView:self];
//    
//    
////    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 60, 200, 40)];
////    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
////    //loginButton.center = self.center;
////    [self addSubview:loginButton];
//    
//    
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:FacebookLogin"]) {
//        
//        [MFLoginView facebookLogin];
//        
//        return NO;
//    }
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:GetContacts"]) {
//        
//        NSString *contacts = [[MFAddressBook getContacts] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//        NSString *function = [NSString stringWithFormat:@"iOSContacts(\"%@\")", contacts];
//        
//        [self.webView stringByEvaluatingJavaScriptFromString:function];
//        
//        return NO;
//    }
//    /*
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromCreate"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
//        
//        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:nil];
//        [MFHelpers open:addressBook onView:self];
//
//        return NO;
//    }
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromDetails"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
//        NSRange eventParam = [params rangeOfString:@"&currentEvent="];
//        NSString *eventUrl = [params substringFromIndex:eventParam.location + eventParam.length];
//        
//        Event *event = [[Event alloc] initFromUrl:eventUrl];
//        
//        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:event];
//        [MFHelpers open:addressBook onView:self];
//        
//        return NO;
//    }
//    */
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:SendSMS"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location + 1];
//        
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        for (NSString *keyValuePair in [params componentsSeparatedByString:@"&"])
//        {
//            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
//            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
//            
//            [dict setObject:value forKey:key];
//        }
//
//        ViewController *vc = (ViewController *)self.window.rootViewController;
//        [vc sendTextMessage:[[dict objectForKey:@"phone"] componentsSeparatedByString:@","] message:[dict objectForKey:@"message"]];
//        
//        return NO;
//    }
//    
//    return YES;
//}
//
//-(void)sendLatLngToWeb
//{
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    if(location == NULL)
//        return;
//    
//    NSString *function = [NSString stringWithFormat:@"ReceiveLocation(\"%f\",\"%f\")", location.latitude, location.longitude];    
//    if(self.webView != NULL)
//        [self.webView stringByEvaluatingJavaScriptFromString:function];
//}
//
//-(void)returnAddressList:(NSString *)params
//{
//        /*
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactList options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [self urlEncodeJSON:jsonString];
//        params = [NSString stringWithFormat:@"%@&contactList=%@", params, jsonString];
//        */
//        NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/%@", params];
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlAddress]];
//        [self.webView loadRequest:requestObj];
//}
//
//-(void)goToEvent:(NSUInteger)referenceId
//{
//    if(self.webView == nil)
//    {
//        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//        
//        for(UIView *subview in self.subviews)
//            [subview removeFromSuperview];
//        
//        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
//        [self.webView setScalesPageToFit:YES];
//        self.webView.scrollView.bounces = NO;
//        self.webView.delegate = self;
//        [self addSubview:self.webView];
//    }
//    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&goToEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
//    BOOL toMessaging = [[Session sessionVariables][@"toMessaging"] boolValue];
//    if(toMessaging)
//        urlAddress = [NSString stringWithFormat:@"%@&toMessaging=true", urlAddress];
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//
//    [self.webView loadRequest:requestObj];
//}
//
//-(void)joinEvent:(NSUInteger)referenceId
//{
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&joinEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:requestObj];
//}
//
//-(NSString *)urlEncodeJSON:(NSString *)json;
//{
//    return [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//}
//
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"%@", error);
//}
//
//-(void)webViewDidFinishLoad:(UIWebView *)webView {
//    webView.keyboardDisplayRequiresUserAction = NO;
//    if(!webView.loading)
//        [self sendLatLngToWeb];
//}





@end
