//
//  MFGroupDetailView.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "MFGroupDetailView.h"

@interface MFGroupDetailView ()

@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, strong) NSMutableArray *Events;
@property (nonatomic, strong) UIView *menuView;
@end

@implementation MFGroupDetailView

-(id)init:(Group *)group
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.Events = [[NSMutableArray alloc] init];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        [self setup:group];
    }
    return self;
}

-(void)setup:(Group *)group
{
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    self.group = group;

    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;

    [MFHelpers addTitleBar:self titleText:group.name];

    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];

    [group isAdmin:^(GroupUsers *groupUser) {
        if(groupUser.isAdmin == true) {
            UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 30, 28, 25, 25)];
            [menuButton setImage:[UIImage imageNamed:@"smallmenu"] forState:UIControlStateNormal];
            [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:menuButton];
        }
    }];
    
    UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    [self addSubview:detailView];

    int viewY = 20;
    School *school = (School *)[Session sessionVariables][@"currentSchool"];

    UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 20)];
    NSString *details = group.members.count > 5 ? [NSString stringWithFormat:@"%lu Members - %@", (unsigned long)group.members.count, school.name] : school.name;
    detailsLabel.text = details;
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    self.detailsLabel = detailsLabel;
    [detailView addSubview:detailsLabel];
    viewY += 40;
    
    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    joinButton.frame = CGRectMake(30, viewY, wd - 60, 40);
    joinButton.layer.cornerRadius = 4.0f;
    joinButton.layer.borderWidth = 2.0f;
    [detailView addSubview:joinButton];
    
    if(group.pictureUrl.length > 0) {
         MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(30, 20, 70, 70) url:group.pictureUrl];
         [detailView addSubview:pic];
         
         detailsLabel.frame = CGRectMake(120, 20, wd - 140, 20);
         joinButton.frame = CGRectMake(120, 60, wd - 140, 40);
    }

    if(![group isMember])
    {
        [joinButton setTitle:@"+ ADD INTEREST" forState:UIControlStateNormal];
        [joinButton setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        joinButton.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        joinButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    else
    {
        [joinButton setTitle:@"MEMBER" forState:UIControlStateNormal];
        [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        joinButton.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        joinButton.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
    }
    viewY += 50;

    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 20)];
    descriptionLabel.text = [group.description stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [descriptionLabel sizeToFit];
    [detailView addSubview:descriptionLabel];

    viewY += descriptionLabel.frame.size.height;

    //TODO: Invite Friends
    viewY += 20;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [detailView addSubview:bottomBorder];
    viewY += 1;
    
    int i = 0;
    NSArray *events = (NSArray *)[Session sessionVariables][@"currentEvents"];
    for(Event *event in events) {
        if([event.groupId rangeOfString:group.groupId].location != NSNotFound)
        {
            [self.Events addObject:event];
            
            UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
            [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
            eventView.backgroundColor = [UIColor whiteColor];
            eventView.tag = i;
            [detailView addSubview:eventView];
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
            timeLabel.text = event.localTime;
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
        detailView.contentSize = CGSizeMake(wd, viewY + 20);
    }

}

-(void)refreshGroup
{
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    if(self.group.members.count > 5)
        self.detailsLabel.text = [NSString stringWithFormat:@"%lu Members - %@",(unsigned long)self.group.members.count, school.name];
    else
        self.detailsLabel.text = school.name;
}

-(void)joinButtonClick:(id)sender
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];

    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"+ ADD INTEREST"])
    {
        [button setTitle:@"MEMBER" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        
        [self.group addMember:currentUser.userId isAdmin:NO];
        
        GroupUsers *person = [[GroupUsers alloc] init];
        person.firstName = currentUser.firstName;
        person.facebookId = currentUser.facebookId;
        person.userId = currentUser.userId;
        NSMutableArray *members = [[NSMutableArray alloc] initWithArray:self.group.members];
        [members addObject:person];
        self.group.members = [[NSArray alloc] initWithArray:members];
        
        [self refreshGroup];
    }
    else
    {
        
        [button setTitle:@"+ ADD INTEREST" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        [self.group removeMember:currentUser.userId];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        for(GroupUsers *member in self.group.members)
        {
            if(![member.userId isEqualToString:currentUser.userId])
                [members addObject:member];
        }
        self.group.members = [[NSArray alloc] initWithArray:members];
        
        [self refreshGroup];
    }
    
    if(self.group.isPublic == NO && [self.superview isMemberOfClass:[MFView class]]) {
        MFView *view = (MFView *)self.superview;
        [view refreshEvents];
    }
}

-(void)eventClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    Event *event = self.Events[button.tag];
    
    MFDetailView *detailView = [[MFDetailView alloc] init:event];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

-(void)menuButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    self.menuView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.menuView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    [self.menuView addGestureRecognizer:singleTap];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editButton setTitle:@"Edit Interest" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(20, ht - 60, wd - 40, 40);
    editButton.backgroundColor = [UIColor whiteColor];
    [editButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    editButton.layer.cornerRadius = 5;
    [self.menuView addSubview:editButton];
}

-(void)closeMenu
{
    [self.menuView removeFromSuperview];
}

-(void)editButtonClick:(id)sender
{
    MFCreateGroupView *createView = [[MFCreateGroupView alloc] init:self.group];
    [MFHelpers openFromRight:createView onView:self.superview];
    [self closeMenu];
}

-(void)cancelButtonClick:(id)sender
{
    [MFHelpers closeRight:self];
}

@end
