//
//  MFProfileView.m
//  Pow Wow
//
//  Created by Will Parks on 2/24/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFProfileView.h"

@interface MFProfileView ()

@property (nonatomic, strong) UIScrollView *userView;
@property (nonatomic, strong) UIView *selectedBorder;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, assign) int origViewY;
@property (nonatomic, assign) BOOL isCurrentUser;
@property (nonatomic, strong) NSMutableArray *Events;
@property (nonatomic, strong) UIView *eventsView;
@property (nonatomic, assign) int eventsHt;
@property (nonatomic, strong) UIView *picturesView;
@property (nonatomic, assign) int picturesHt;
@property (nonatomic, strong) NSMutableArray *Groups;
@property (nonatomic, assign) long currentIndex;
@property (nonatomic, strong) UIView *interestsView;
@property (nonatomic, assign) int interestsHt;

@end

@implementation MFProfileView

- (id)init:(NSString *)facebookId
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    [self setup:facebookId];
    
    return self;
}

-(void)setup:(NSString *)facebookId {
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.frame = CGRectMake(0, 0, wd, ht);
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer1];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if([currentUser.facebookId isEqualToString:facebookId]) {
        self.isCurrentUser = YES;
        [self populateUser:currentUser];
    }
    else {
        [User getByFacebookId:facebookId completion:^(User *user) {
            self.isCurrentUser = NO;
            [self populateUser:user];
        }];
    }
}

-(void)populateUser:(User *)user {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    [MFHelpers addTitleBar:self titleText:user.name];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    
    UIScrollView *userView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, self.frame.size.height - 60)];
    self.userView = userView;
    [self addSubview:userView];
    int viewY = 0;
    
    int picWd = ((int)wd / 2) - 40;
    UIButton *profilePic = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, picWd, picWd)];
    profilePic.imageView.layer.cornerRadius = picWd / 2;
    
    dispatch_queue_t queue = dispatch_queue_create("Facebook Profile Image Queue", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", user.facebookId, picWd * 2, picWd * 2]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [profilePic setImage:img forState:UIControlStateNormal];
        });
    });

    [userView addSubview:profilePic];
    
    self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, picWd / 2 + 10, wd - picWd + 40, 20)];
    self.pointsLabel.text = @"0";
    self.pointsLabel.textAlignment = NSTextAlignmentRight;
    [self.pointsLabel setFont:[UIFont systemFontOfSize:24.0]];
    [userView addSubview:self.pointsLabel];
    
    UIImageView *litImage = [[UIImageView alloc] initWithFrame:CGRectMake(wd - picWd + 20, 15, picWd - 10, picWd - 10)];
    [litImage setImage:[UIImage imageNamed:@"match"]];
    [userView addSubview:litImage];
    viewY += picWd + 30;
    
    UIView *topBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    topBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [userView addSubview:topBorder1];
    viewY += 1;
    
    UIView *middle1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 10)];
    middle1.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [userView addSubview:middle1];
    viewY += 10;
    
    UIView *bottomBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    bottomBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [userView addSubview:bottomBorder1];
    viewY += 10;
    
    UIButton *eventsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd/3, 20)];
    [eventsButton setTitle:@"Events" forState:UIControlStateNormal];
    [eventsButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [eventsButton setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    eventsButton.tag = 1;
    [userView addSubview:eventsButton];
    
    UIView *buttonSeperator1 = [[UIView alloc] initWithFrame:CGRectMake(wd/3 - 1, viewY, 1, 20)];
    buttonSeperator1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [userView addSubview:buttonSeperator1];
    
    UIButton *picturesButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/3, viewY, wd/3, 20)];
    [picturesButton setTitle:@"Pictures" forState:UIControlStateNormal];
    [picturesButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [picturesButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [picturesButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    picturesButton.tag = 2;
    [userView addSubview:picturesButton];
    
    UIView *buttonSeperator2 = [[UIView alloc] initWithFrame:CGRectMake((2 * wd) / 3 - 1, viewY, 1, 20)];
    buttonSeperator2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [userView addSubview:buttonSeperator2];
    
    UIButton *interestsButton = [[UIButton alloc] initWithFrame:CGRectMake((wd * 2) / 3, viewY, wd/3, 20)];
    [interestsButton setTitle:@"Interests" forState:UIControlStateNormal];
    [interestsButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [interestsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    interestsButton.tag = 3;
    [userView addSubview:interestsButton];
    viewY += 30;
    
    UIView *buttonbottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    buttonbottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    buttonbottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
    buttonbottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    buttonbottomBorder.layer.shadowRadius = 3.0f;
    buttonbottomBorder.layer.shadowOpacity = 1.0f;
    [userView addSubview:buttonbottomBorder];
    
    UIView *coverBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY - 8, wd, 8)];
    coverBottomBorder.backgroundColor = [UIColor whiteColor];
    [userView addSubview:coverBottomBorder];
    
    self.selectedBorder = [[UIView alloc] initWithFrame:CGRectMake(2, viewY - 3, wd / 3 - 4, 4)];
    self.selectedBorder.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0];
    [userView addSubview:self.selectedBorder];
    viewY += 12;
    
    self.origViewY = viewY;
    
    [self loadPoints:user];
    [self loadEvents:user];
    [self loadPictures:user];
    [self loadInterests:user];
}

-(void)loadPoints:(User *)user {
    if([self.pointsLabel.text isEqualToString:@"0"]) {
        [user getPoints:^(int points) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            self.pointsLabel.text = [formatter stringFromNumber:[NSNumber numberWithInteger:points]];
        }];
    }
}

-(void)loadEvents:(User *)user {
    [Event getByUserId:user.userId completion:^(NSArray *events) {
        [self populateEvents:events];
    }];
}

-(void)loadPictures:(User *)user {
//    [Event getByUserId:user.userId completion:^(NSArray *events) {
//        
//    }];
}

-(void)loadInterests:(User *)user {
    [Group getByUser:user.userId completion:^(NSArray *groups) {
        [self populateInterests:groups];
    }];
}

-(void)populateEvents:(NSArray *)events {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    int i = 0;
    int viewY = 0;
    self.eventsView = [[UIView alloc] init];
    [self.userView addSubview:self.eventsView];
    
    self.Events = [[NSMutableArray alloc] init];
    for(Event *event in events) {
        
        if(event.isPrivate) {
            continue;
        }
        else if(!self.isCurrentUser) {
            NSDate *now = [NSDate date];
            NSDate *fourteenDaysAgo = [now dateByAddingTimeInterval:-14*24*60*60];
            if ([event.startTime compare:fourteenDaysAgo] == NSOrderedAscending) {
                continue;
            }
        }
        [self.Events addObject:event];
        
        UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
        [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
        eventView.backgroundColor = [UIColor whiteColor];
        eventView.tag = i;
        [self.eventsView addSubview:eventView];
        i++;
        
        //Icon
        if(![event.groupPictureUrl isKindOfClass:[NSNull class]] && event.groupPictureUrl.length > 0) {
            if([event.groupPictureUrl rangeOfString:@".com"].location == NSNotFound)
            {
                UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
                [icon setImage:[UIImage imageNamed:event.groupPictureUrl]];
                [eventView addSubview:icon];
            }
            else {
                MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(10, 10, 60, 60) url:event.groupPictureUrl];
                [eventView addSubview:pic];
            }
        }
        
        if(event.isGoing) {
            UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(50, 47, 22, 22)];
            picBackground.backgroundColor = [UIColor whiteColor];
            picBackground.layer.cornerRadius = 11;
            picBackground.layer.borderColor = [UIColor colorWithRed:7.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor;
            picBackground.layer.borderWidth = 1;
            [eventView addSubview:picBackground];
            
            UIImageView *checkPic = [[UIImageView alloc] initWithFrame:CGRectMake(55, 52, 13, 13)];
            [checkPic setImage:[UIImage imageNamed:@"greenCheck"]];
            [eventView addSubview:checkPic];
        }
        else if(event.isInvited) {
            UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(52, 49, 22, 22)];
            picBackground.backgroundColor = [UIColor whiteColor];
            picBackground.layer.cornerRadius = 11;
            picBackground.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
            picBackground.layer.borderWidth = 1;
            [eventView addSubview:picBackground];
            
            UIImageView *invitePic = [[UIImageView alloc] initWithFrame:CGRectMake(55, 52, 16, 16)];
            [invitePic setImage:[UIImage imageNamed:@"invited"]];
            [eventView addSubview:invitePic];
        }
        
        int nameWidth = (int)(wd - (105 + (wd / 4)));
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, nameWidth, 20)];
        nameLabel.text = event.name;
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [nameLabel sizeToFit];
        [eventView addSubview:nameLabel];
        
        int nameHeight = ceil(nameLabel.frame.size.height);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d"];
        NSString *dayText = [dateFormatter stringFromDate:event.startTime];
        NSString *todayText = [dateFormatter stringFromDate:[NSDate date]];
        NSString *tomorrowText = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:60*60*24]];
        if([dayText isEqualToString:todayText])
            dayText = @"Today";
        else if([dayText isEqualToString:tomorrowText])
            dayText = @"Tomorrow";
        
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/4 - 20, 15, wd/4 + 10, 20)];
        dayLabel.text = dayText;
        [dayLabel setFont:[UIFont systemFontOfSize:18]];
        [eventView addSubview:dayLabel];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/4 - 20, 40, wd/4 + 10, 20)];
        timeLabel.text = [event.localTime isKindOfClass:[NSNull class]] ? @"" : event.localTime;
        [timeLabel setFont:[UIFont systemFontOfSize:18]];
        [eventView addSubview:timeLabel];
        
        if(nameHeight + 30 > eventView.frame.size.height) {
            eventView.frame = CGRectMake(0, viewY, wd, nameHeight + 30);
        }
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(15, eventView.frame.size.height - 1.0f, eventView.frame.size.width - 35, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [eventView addSubview:bottomBorder];
        
        viewY += eventView.frame.size.height;
    }
    self.eventsView.frame = CGRectMake(0, self.origViewY, wd, viewY + 20);
    self.userView.contentSize = CGSizeMake(wd, self.origViewY + viewY + 20);
}

-(void)eventClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    Event *event = self.Events[button.tag];
    
    MFDetailView *detailView = [[MFDetailView alloc] init:event];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

-(void)populateInterests:(NSArray *)groups {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSArray *events = (NSArray *)[Session sessionVariables][@"currentEvents"];
    
    int viewY = 0;
    int i = 0;
    self.interestsView = [[UIView alloc] init];
    [self.userView addSubview:self.interestsView];
    self.Groups = [[NSMutableArray alloc] init];
    for(Group *group in groups)
    {
        UIButton *groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 50)];
        [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
        groupView.tag = i;
        [self.interestsView addSubview:groupView];
        [self.Groups addObject:group];
        i++;
        
        if([group.pictureUrl length] > 0)
        {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(5, 5, 40, 40) url:group.pictureUrl];
            [groupView addSubview:pic];
        }
        else {
            UIImageView *groupImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
            [groupImg setImage:[UIImage imageNamed:@"group"]];
            [groupView addSubview:groupImg];
        }
        
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, wd - 60, 50)];
        [groupLabel setText:[NSString stringWithFormat:@"%@", group.name]];
        //groupLabel.textColor = [UIColor whiteColor];
        [groupLabel setFont:[UIFont systemFontOfSize:16]];
        [groupView addSubview:groupLabel];
        
        int eventCt = 0;
        for(Event *event in events) {
            if(![event.primaryGroupId isMemberOfClass:[NSNull class]] && [event.primaryGroupId isEqualToString:group.groupId]) {
                eventCt++;
            }
        }
        if (eventCt > 0) {
            groupLabel.frame = CGRectMake(60, 0, wd - 60, 32);
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 26, wd - 60, 20)];
            NSString *eventText = eventCt == 1 ? @"1 upcoming event" : [NSString stringWithFormat:@"%i upcoming events", eventCt];
            [eventLabel setText:eventText];
            eventLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            [eventLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [groupView addSubview:eventLabel];
        }
        
        if(group.isPublic == false) {
            UIImageView *privateImg = [[UIImageView alloc] initWithFrame:CGRectMake(wd - 40, 12, 25, 25)];
            [privateImg setImage:[UIImage imageNamed:@"solidgraylock"]];
            [groupView addSubview:privateImg];
        }
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(10, groupView.frame.size.height - 1.0f, groupView.frame.size.width - 25, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [groupView addSubview:bottomBorder];
        viewY += 50;
    }
    self.interestsView.frame = CGRectMake(wd, self.origViewY, wd, viewY + 20);
    self.userView.contentSize = CGSizeMake(wd, self.origViewY + viewY + 20);
}

-(void)groupClicked:(id)sender
{   
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;
    
    Group *group = (Group *)[self.Groups objectAtIndex:tagId];
    if(group.isPublic == false && group.isMember == false) {
        
        self.currentIndex = tagId;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is private", group.name]
                                                        message:@"Enter Password"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else {
        [self openGroup:group];
    }
}

-(void)openGroup:(Group *)group {
    MFGroupDetailView *detailView = [[MFGroupDetailView alloc] init:group];
    [MFHelpers openFromRight:detailView onView:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        NSString *password = [alertView textFieldAtIndex:0].text;
        Group *group = self.Groups[self.currentIndex];
        if([password isEqualToString:group.password]) {
            [self openGroup:group];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect password"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)buttonClick:(id)sender {
    if(self.eventsView == nil || self.interestsView == nil) { //|| self.picturesView == nil
        return;
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIButton *button = (UIButton *)sender;
    for(UIView *subview in self.userView.subviews) {
        if([subview isKindOfClass:[UIButton class]]) {
            if(subview.tag == button.tag) {
                [button setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
            }
            else if(subview.tag > 0) {
                UIButton *otherButton = (UIButton *)subview;
                [otherButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [otherButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            }
        }
    }
    int i = (int)button.tag;
    self.selectedBorder.frame = CGRectMake(((wd  * (i - 1)) / 3) + 2, self.selectedBorder.frame.origin.y, self.selectedBorder.frame.size.width, self.selectedBorder.frame.size.height);
    
    if(i == 1) {
        self.eventsView.frame = CGRectMake(0, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
        self.picturesView.frame = CGRectMake(wd, self.picturesView.frame.origin.y, self.picturesView.frame.size.width, self.picturesView.frame.size.height);
        self.interestsView.frame = CGRectMake(wd, self.interestsView.frame.origin.y, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
    } else if (i == 2) {
        self.eventsView.frame = CGRectMake(wd, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
        self.picturesView.frame = CGRectMake(0, self.picturesView.frame.origin.y, self.picturesView.frame.size.width, self.picturesView.frame.size.height);
        self.interestsView.frame = CGRectMake(wd, self.interestsView.frame.origin.y, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
    } else {
        self.eventsView.frame = CGRectMake(wd, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
        self.picturesView.frame = CGRectMake(wd, self.picturesView.frame.origin.y, self.picturesView.frame.size.width, self.picturesView.frame.size.height);
        self.interestsView.frame = CGRectMake(0, self.interestsView.frame.origin.y, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
    }
    
}


-(void)cancelButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(wd, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                     }];
    
}

-(void)nothing:(id)sender {
    
}

@end

