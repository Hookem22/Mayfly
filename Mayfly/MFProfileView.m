//
//  MFProfileView.m
//  Pow Wow
//
//  Created by Will Parks on 2/24/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFProfileView.h"

@interface MFProfileView ()

@property (nonatomic, strong) UIView *userView;
@property (nonatomic, strong) UIView *selectedBorder;
@property (nonatomic, strong) UILabel *pointsLabel;
@property (nonatomic, assign) int origViewY;
@property (nonatomic, assign) BOOL isCurrentUser;
@property (nonatomic, strong) NSMutableArray *UpcomingEvents;
@property (nonatomic, strong) NSMutableArray *PastEvents;
@property (nonatomic, strong) UIView *eventsView;
@property (nonatomic, assign) int eventsHt;
@property (nonatomic, strong) UIScrollView *picturesView;
@property (nonatomic, assign) int picturesHt;
@property (nonatomic, strong) NSMutableArray *Groups;
@property (nonatomic, assign) long currentIndex;
@property (nonatomic, strong) UIView *interestsView;
@property (nonatomic, assign) int interestsHt;
@property (nonatomic, strong) UIView *bottomButtonsView;

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
    
//    UIButton *eventsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd/3, 20)];
//    [eventsButton setTitle:@"Events" forState:UIControlStateNormal];
//    [eventsButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [eventsButton setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//    eventsButton.tag = 1;
//    [userView addSubview:eventsButton];
//    
//    UIView *buttonSeperator1 = [[UIView alloc] initWithFrame:CGRectMake(wd/3 - 1, viewY, 1, 20)];
//    buttonSeperator1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//    [userView addSubview:buttonSeperator1];
//    
//    UIButton *picturesButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/3, viewY, wd/3, 20)];
//    [picturesButton setTitle:@"Pictures" forState:UIControlStateNormal];
//    [picturesButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [picturesButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [picturesButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//    picturesButton.tag = 2;
//    [userView addSubview:picturesButton];
//    
//    UIView *buttonSeperator2 = [[UIView alloc] initWithFrame:CGRectMake((2 * wd) / 3 - 1, viewY, 1, 20)];
//    buttonSeperator2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//    [userView addSubview:buttonSeperator2];
//    
//    UIButton *interestsButton = [[UIButton alloc] initWithFrame:CGRectMake((wd * 2) / 3, viewY, wd/3, 20)];
//    [interestsButton setTitle:@"Interests" forState:UIControlStateNormal];
//    [interestsButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    [interestsButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
//    interestsButton.tag = 3;
//    [userView addSubview:interestsButton];
//    viewY += 30;
//    
//    UIView *buttonbottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
//    buttonbottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//    buttonbottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
//    buttonbottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    buttonbottomBorder.layer.shadowRadius = 3.0f;
//    buttonbottomBorder.layer.shadowOpacity = 1.0f;
//    [userView addSubview:buttonbottomBorder];
//    
//    UIView *coverBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY - 8, wd, 8)];
//    coverBottomBorder.backgroundColor = [UIColor whiteColor];
//    [userView addSubview:coverBottomBorder];
//    
//    self.selectedBorder = [[UIView alloc] initWithFrame:CGRectMake(2, viewY - 3, wd / 3 - 4, 4)];
//    self.selectedBorder.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0];
//    [userView addSubview:self.selectedBorder];
    
    self.origViewY = viewY;
    
    [self addBottomButtons];
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


///Events
-(void)loadEvents:(User *)user {
    [Event getByUserId:user.userId completion:^(NSArray *events) {
        [self populateEvents:events];
    }];
}

-(void)populateEvents:(NSArray *)events {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    self.eventsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.origViewY, wd, ht - self.origViewY - 60)];
    [self.userView addSubview:self.eventsView];
    
    self.UpcomingEvents = [[NSMutableArray alloc] init];
    self.PastEvents = [[NSMutableArray alloc] init];
    for(Event *event in events) {
        
        if(event.isPrivate) {
            continue;
        }
        if(!self.isCurrentUser) {
            NSDate *now = [NSDate date];
            NSDate *fourteenDaysAgo = [now dateByAddingTimeInterval:-14*24*60*60];
            if ([event.startTime compare:fourteenDaysAgo] == NSOrderedAscending) {
                continue;
            }
        }
        if(![event.schoolId isEqualToString:school.schoolId]) {
            continue;
        }
        
        NSDate *now = [NSDate date];
        NSDate *twoHoursAgo = [now dateByAddingTimeInterval:-2*60*60];
        if ([event.startTime compare:twoHoursAgo] == NSOrderedAscending) {
            [self.PastEvents addObject:event];
        }
        else {
            [self.UpcomingEvents addObject:event];
        }
    }
    
    self.UpcomingEvents = [[[self.UpcomingEvents reverseObjectEnumerator] allObjects] mutableCopy];
    UIScrollView *upcomingEventsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, wd, self.eventsView.frame.size.height - 80)];
    upcomingEventsView.tag = 1;
    [self.eventsView addSubview:upcomingEventsView];
    
    [self addEventItems:self.UpcomingEvents scrollView:upcomingEventsView];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(eventsScrollToPast:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [upcomingEventsView addGestureRecognizer:recognizer1];
    
    UIScrollView *pastEventsView = [[UIScrollView alloc] initWithFrame:CGRectMake(wd, 30, wd, self.eventsView.frame.size.height - 80)];
    pastEventsView.tag = 2;
    [self.eventsView addSubview:pastEventsView];
    
    [self addEventItems:self.PastEvents scrollView:pastEventsView];
    
    UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(eventsScrollToUpcoming:)];
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [pastEventsView addGestureRecognizer:recognizer2];
    
    [self addEventsButtons];
}

-(void)addEventItems:(NSArray *)events scrollView:(UIScrollView *)scrollView {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    int viewY = 0;
    int i = 0;
    for(Event *event in events) {
        UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
        if(scrollView.tag == 1)
            [eventView addTarget:self action:@selector(upcomingEventClicked:) forControlEvents:UIControlEventTouchUpInside];
        else
            [eventView addTarget:self action:@selector(pastEventClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        eventView.backgroundColor = [UIColor whiteColor];
        eventView.tag = i;
        [scrollView addSubview:eventView];
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
    scrollView.contentSize = CGSizeMake(wd, viewY + 10);
}

-(void)addEventsButtons {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    int viewY = 0;
    
    UIButton *upcomingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd/2, 20)];
    [upcomingButton setTitle:@"UPCOMING" forState:UIControlStateNormal];
    [upcomingButton addTarget:self action:@selector(eventsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [upcomingButton setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [upcomingButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    upcomingButton.tag = 1;
    [self.eventsView addSubview:upcomingButton];
    
    UIView *buttonSeperator1 = [[UIView alloc] initWithFrame:CGRectMake(wd/2 - 1, viewY, 1, 20)];
    buttonSeperator1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.eventsView addSubview:buttonSeperator1];
    
    UIButton *pastButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/2, viewY, wd/2, 20)];
    [pastButton setTitle:@"PAST" forState:UIControlStateNormal];
    [pastButton addTarget:self action:@selector(eventsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pastButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [pastButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    pastButton.tag = 2;
    [self.eventsView addSubview:pastButton];
    viewY += 30;
    
    UIView *buttonbottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    buttonbottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    buttonbottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
    buttonbottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    buttonbottomBorder.layer.shadowRadius = 3.0f;
    buttonbottomBorder.layer.shadowOpacity = 1.0f;
    [self.eventsView addSubview:buttonbottomBorder];
    
    UIView *coverBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY - 8, wd, 8)];
    coverBottomBorder.backgroundColor = [UIColor whiteColor];
    [self.eventsView addSubview:coverBottomBorder];
    
    self.selectedBorder = [[UIView alloc] initWithFrame:CGRectMake(2, viewY - 3, wd / 2 - 4, 4)];
    self.selectedBorder.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0];
    [self.eventsView addSubview:self.selectedBorder];
}

-(void)eventsButtonClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self eventsSwitch:(int)button.tag];
}

-(void)eventsScrollToPast:(id)sender {
    [self eventsSwitch:2];
}

-(void)eventsScrollToUpcoming:(id)sender {
    [self eventsSwitch:1];
}

-(void)eventsSwitch:(int)tag {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(UIView *subview in self.eventsView.subviews) {
        if([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            if(scrollView.tag == tag) {
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     scrollView.frame = CGRectMake(0, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){ }];
            } else {
                int newWd = scrollView.tag == 1 ? -1 * (int)wd : (int)wd;
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     scrollView.frame = CGRectMake(newWd, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){ }];
            }
        }
        if([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if(button.tag == tag) {
                [button setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
                
            } else {
                [button setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
            }
        }
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.selectedBorder.frame = CGRectMake(((wd  * (tag - 1)) / 2) + 2, self.selectedBorder.frame.origin.y, self.selectedBorder.frame.size.width, self.selectedBorder.frame.size.height);
                     }
                     completion:^(BOOL finished){ }];
}

-(void)upcomingEventClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    Event *event = self.UpcomingEvents[button.tag];
    
    MFDetailView *detailView = [[MFDetailView alloc] init:event];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

-(void)pastEventClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    Event *event = self.PastEvents[button.tag];
    
    MFDetailView *detailView = [[MFDetailView alloc] init:event];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

///Pictures
-(void)loadPictures:(User *)user {
    [Message getImageByUser:user.userId completion:^(NSArray *messages) {
        [self populatePictures:messages user:user];
    }];
}

-(void)populatePictures:(NSArray *)messages user:(User *)user {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    int picWd = (int)wd / 3 - 2;
    self.picturesView = [[UIScrollView alloc] initWithFrame:CGRectMake(wd, self.origViewY, wd, ht - self.origViewY - 110)];
    self.picturesView.backgroundColor = [UIColor whiteColor];
    [self.userView addSubview:self.picturesView];
    
    UIButton *profilePic = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, picWd, picWd)];
    [profilePic addTarget:self action:@selector(pictureClicked:) forControlEvents:UIControlEventTouchUpInside];
    profilePic.tag = 0;
    [self loadMessagePicture:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%lu&height=%lu", user.facebookId, (unsigned long)wd, (unsigned long)wd] imgButton:profilePic];
    [self.picturesView addSubview:profilePic];

    int tag = 1;
    NSString *messagePath = @"https://mayflyapp.blob.core.windows.net/messages/";
    for(Message *message in messages) {
        int picX = (tag % 3 * (int)wd) / 3 + (tag % 3);
        int picY = (floor(tag / 3) * wd) / 3 + floor(tag / 3) * 2;
        UIButton *pic = [[UIButton alloc] initWithFrame:CGRectMake(picX, picY, picWd, picWd)];
        [pic addTarget:self action:@selector(pictureClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self loadMessagePicture:[NSString stringWithFormat:@"%@%@.jpeg", messagePath, message.messageId] imgButton:pic];
        [self.picturesView addSubview:pic];
        tag++;
    }
    self.picturesView.contentSize = CGSizeMake(wd, ((floor(tag / 3) + 1) * wd) / 3 + floor(tag / 3) * 2 + 10);
    
}

-(void)loadMessagePicture:(NSString *)urlString imgButton:(UIButton *)imgButton {
    dispatch_queue_t queue = dispatch_queue_create("Image Queue", NULL);
    dispatch_async(queue, ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imgButton setImage:img forState:UIControlStateNormal];
        });
    });
}

-(void)pictureClicked:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UIView *pictureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    pictureView.tag = 100;
    pictureView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [self addSubview:pictureView];
    
    UIButton *button = (UIButton *)sender;
    UIImage *img = [button imageForState:UIControlStateNormal];
    
    int picHt = (wd / img.size.width) * img.size.height;
    int picY = ((int)ht - picHt) / 2;
    if(picY == 0)
        picY = 0;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, picY, wd, picHt)];
    [imageView setImage:img];
    [pictureView addSubview:imageView];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closePicture:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [pictureView addGestureRecognizer:recognizer];
    
}

-(void)closePicture:(id)sender {
    for(UIView *subview in self.subviews)
    {
        if(subview.tag == 100) {
            NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
            NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 subview.frame = CGRectMake(wd, 0, wd, ht);
                             }
                             completion:^(BOOL finished){
                                 [subview removeFromSuperview];
                             }];
        }
    }
}

///Interests
-(void)loadInterests:(User *)user {
    [Group getByUser:user.userId completion:^(NSArray *groups) {
        [self populateInterests:groups];
    }];
}

-(void)populateInterests:(NSArray *)groups {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;

    NSArray *events = (NSArray *)[Session sessionVariables][@"currentEvents"];
    
    int viewY = 0;
    int i = 0;
    self.interestsView = [[UIView alloc] initWithFrame:CGRectMake(wd, self.origViewY, wd, ht - self.origViewY - 60)];
    self.interestsView.backgroundColor = [UIColor whiteColor];
    [self.userView addSubview:self.interestsView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 34, wd, self.interestsView.frame.size.height - 80)];
    [self.interestsView addSubview:scrollView];
    
    self.Groups = [[NSMutableArray alloc] init];
    for(Group *group in groups)
    {
        UIButton *groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 50)];
        [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
        groupView.tag = i;
        [scrollView addSubview:groupView];
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
    scrollView.contentSize = CGSizeMake(wd, viewY + 10);
    
    UILabel *interestsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 20)];
    interestsLabel.text = @"INTERESTS";
    interestsLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
    interestsLabel.textAlignment = NSTextAlignmentCenter;
    [interestsLabel setFont:[UIFont systemFontOfSize:16.0]];
    [self.interestsView addSubview:interestsLabel];
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 30, wd, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    bottomBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
    bottomBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    bottomBorder.layer.shadowRadius = 3.0f;
    bottomBorder.layer.shadowOpacity = 1.0f;
    [self.interestsView addSubview:bottomBorder];
    
    UIView *coverBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 22, wd, 8)];
    coverBottomBorder.backgroundColor = [UIColor whiteColor];
    [self.interestsView addSubview:coverBottomBorder];

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
    [Group get:group.groupId completion:^(Group *retGroup) {
        MFGroupDetailView *detailView = [[MFGroupDetailView alloc] init:retGroup];
        [MFHelpers openFromRight:detailView onView:self];
    }];
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

-(void)addBottomButtons {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.bottomButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, ht - 50, wd, 50)];
    self.bottomButtonsView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    [self addSubview:self.bottomButtonsView];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
    topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.bottomButtonsView addSubview:topBorder];
    
    UIButton *iconEventsButton = [[UIButton alloc] initWithFrame:CGRectMake(wd / 6 - 10, 10, 20, 20)];
    [iconEventsButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [iconEventsButton setImage:[UIImage imageNamed:@"menueventselected"] forState:UIControlStateNormal];
    iconEventsButton.tag = 4;
    [self.bottomButtonsView addSubview:iconEventsButton];
    
    UIButton *eventsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, wd/3, 20)];
    [eventsButton setTitle:@"Events" forState:UIControlStateNormal];
    [eventsButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [eventsButton setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [eventsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    eventsButton.tag = 1;
    [self.bottomButtonsView addSubview:eventsButton];
    
    UIButton *iconPicturesButton = [[UIButton alloc] initWithFrame:CGRectMake(wd / 2 - 10, 10, 20, 20)];
    [iconPicturesButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [iconPicturesButton setImage:[UIImage imageNamed:@"menucamera"] forState:UIControlStateNormal];
    iconPicturesButton.tag = 5;
    [self.bottomButtonsView addSubview:iconPicturesButton];
    
    UIButton *picturesButton = [[UIButton alloc] initWithFrame:CGRectMake(wd/3, 30, wd/3, 20)];
    [picturesButton setTitle:@"Pictures" forState:UIControlStateNormal];
    [picturesButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [picturesButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [picturesButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    picturesButton.tag = 2;
    [self.bottomButtonsView addSubview:picturesButton];
    
    UIButton *iconInterestsButton = [[UIButton alloc] initWithFrame:CGRectMake((wd * 5) / 6 - 10, 10, 20, 20)];
    [iconInterestsButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [iconInterestsButton setImage:[UIImage imageNamed:@"menustar"] forState:UIControlStateNormal];
    iconInterestsButton.tag = 6;
    [self.bottomButtonsView addSubview:iconInterestsButton];
    
    UIButton *interestsButton = [[UIButton alloc] initWithFrame:CGRectMake((wd * 2) / 3, 30, wd/3, 20)];
    [interestsButton setTitle:@"Interests" forState:UIControlStateNormal];
    [interestsButton addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [interestsButton setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [interestsButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    interestsButton.tag = 3;
    [self.bottomButtonsView addSubview:interestsButton];
}


-(void)bottomButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    int tag = button.tag % 3;
    if(tag == 0)
        tag = 3;
    [self bottomButtonSelect:tag];
}


-(void)bottomButtonSelect:(int)tag {
    if(self.eventsView == nil || self.picturesView == nil || self.interestsView == nil) {
        return;
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIButton *eventsPic;
    UIButton *picturesPic;
    UIButton *interestsPic;
    for(UIView *subview in self.bottomButtonsView.subviews) {
        if([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if(subview.tag == tag) {
                [button setTitleColor:[UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
            else if(subview.tag > 0 && subview.tag < 4) {
                [button setTitleColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
            else if(subview.tag == 4) {
                eventsPic = button;
            }
            else if(subview.tag == 5) {
                picturesPic = button;
            }
            else if(subview.tag == 6) {
                interestsPic = button;
            }
        }
    }
    
    if(tag == 1) {
        [eventsPic setImage:[UIImage imageNamed:@"menueventselected"] forState:UIControlStateNormal];
        [picturesPic setImage:[UIImage imageNamed:@"menucamera"] forState:UIControlStateNormal];
        [interestsPic setImage:[UIImage imageNamed:@"menustar"] forState:UIControlStateNormal];
        
        self.eventsView.frame = CGRectMake(0, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
        self.picturesView.frame = CGRectMake(wd, self.picturesView.frame.origin.y, self.picturesView.frame.size.width, self.picturesView.frame.size.height);
        self.interestsView.frame = CGRectMake(wd, self.interestsView.frame.origin.y, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
    } else if (tag == 2) {
        [eventsPic setImage:[UIImage imageNamed:@"menuevent"] forState:UIControlStateNormal];
        [picturesPic setImage:[UIImage imageNamed:@"menucameraselected"] forState:UIControlStateNormal];
        [interestsPic setImage:[UIImage imageNamed:@"menustar"] forState:UIControlStateNormal];
        
        self.eventsView.frame = CGRectMake(2 * wd, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
        self.picturesView.frame = CGRectMake(0, self.picturesView.frame.origin.y, self.picturesView.frame.size.width, self.picturesView.frame.size.height);
        self.interestsView.frame = CGRectMake(wd, self.interestsView.frame.origin.y, self.interestsView.frame.size.width, self.interestsView.frame.size.height);
    } else {
        [eventsPic setImage:[UIImage imageNamed:@"menuevent"] forState:UIControlStateNormal];
        [picturesPic setImage:[UIImage imageNamed:@"menucamera"] forState:UIControlStateNormal];
        [interestsPic setImage:[UIImage imageNamed:@"menustarselected"] forState:UIControlStateNormal];
        
        self.eventsView.frame = CGRectMake(2 * wd, self.eventsView.frame.origin.y, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
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
                         [self removeFromSuperview];
                     }];
    
}

-(void)nothing:(id)sender {
    
}

@end

