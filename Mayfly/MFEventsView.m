//
//  MFEventsView.m
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFEventsView.h"

@interface MFEventsView ()

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation MFEventsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        self.delegate = self;
    }
    return self;
}

-(void)loadEvents
{
    [Event getBySchool:^(NSArray *events)
     {
         [[Session sessionVariables] setObject:events forKey:@"currentEvents"];
         [self populateAllEvents];

         [MFHelpers hideProgressView:self.superview];
     }];
}

-(void)populateAllEvents
{
    NSArray *currentEvents = (NSArray *)[Session sessionVariables][@"currentEvents"];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(Event *event in currentEvents) {
        if(!event.isPrivate)
            [events addObject:event];
    }
    [self populateEvents:events];
}


-(void)populateMyEvents
{
    NSArray *currentEvents = (NSArray *)[Session sessionVariables][@"currentEvents"];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    for(Event *event in currentEvents) {
         if(event.isGoing || event.isInvited)
             [events addObject:event];
    }
    [self populateEvents:events];
}

-(void)populateEvents:(NSArray *)events
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    int viewY = 0;
        
    for(int i = 0; i < [events count]; i++)
    {
        Event *event = [events objectAtIndex:i];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM d"];
        NSString *dayText = [dateFormatter stringFromDate:event.startTime];
        
        bool newDay = i == 0;
        if(!newDay)
        {
            Event *prevEvent = [events objectAtIndex:i - 1];
            if(![dayText isEqualToString:[dateFormatter stringFromDate:prevEvent.startTime]])
            {
                newDay = true;
            }
        }
        if(newDay)
        {
            
            NSDate *today = [NSDate date];
            NSString *todayText = [dateFormatter stringFromDate:today];
            NSDate *yesterday = [today dateByAddingTimeInterval:(-1)*60*60*24];
            NSString *yesterdayText = [dateFormatter stringFromDate:yesterday];
            NSDate *tomorrow = [today dateByAddingTimeInterval:60*60*24];
            NSString *tomorrowText = [dateFormatter stringFromDate:tomorrow];
            if([yesterdayText isEqualToString:dayText])
                dayText = @"Yesterday";
            else if([todayText isEqualToString:dayText])
                dayText = @"Today";
            else if([tomorrowText isEqualToString:dayText])
                dayText = @"Tomorrow";
            
            UIControl *newDayView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
            [self addSubview:newDayView];
            
            
            UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, newDayView.frame.size.height - 1.0f, newDayView.frame.size.width, 1)];
            bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            [newDayView addSubview:bottomBorder];
            
            UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(20, newDayView.frame.size.height / 2, newDayView.frame.size.width - 40, 1)];
            middleBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            [newDayView addSubview:middleBorder];
            
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 31, wd - 140, 20)];
            dayLabel.text = [NSString stringWithFormat:@"%@", dayText];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
            [dayLabel setFont:[UIFont boldSystemFontOfSize:18]];
            [newDayView addSubview:dayLabel];
            
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:dayLabel.font, NSFontAttributeName, nil];
            int dayWidth = [[[NSAttributedString alloc] initWithString:dayLabel.text attributes:attributes] size].width;
            dayLabel.frame = CGRectMake(((wd - dayWidth) / 2) - 20, 31, dayWidth + 40, 20);
            
            viewY += 80;
        }
        
        
        UIView *eventView = [self addEventView:event viewY:viewY];
        
        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, viewY + eventView.frame.size.height - 3.0f, eventView.frame.size.width, 1)];
        bottomShadow.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        bottomShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
        bottomShadow.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        bottomShadow.layer.shadowRadius = 3.0f;
        bottomShadow.layer.shadowOpacity = 1.0f;
        [self addSubview:bottomShadow];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, eventView.frame.size.height - 1.0f, eventView.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [eventView addSubview:bottomBorder];
        
        [self addSubview:eventView];
        viewY += eventView.frame.size.height;
    }
    
    self.contentSize = CGSizeMake(wd, viewY + 120);
    
    if(self.contentSize.height < ht)
        self.contentSize = CGSizeMake(wd, ht - 40);
}

-(UIView *)addEventView:(Event *)event viewY:(int)viewY {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 90)];
    [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
    eventView.backgroundColor = [UIColor whiteColor];
    eventView.tag = event.tagId;
    
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
        UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(52, 49, 22, 22)];
        picBackground.backgroundColor = [UIColor whiteColor];
        picBackground.layer.cornerRadius = 11;
        picBackground.layer.borderColor = [UIColor colorWithRed:7.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor;
        picBackground.layer.borderWidth = 1;
        [eventView addSubview:picBackground];
        
        UIImageView *checkPic = [[UIImageView alloc] initWithFrame:CGRectMake(57, 54, 13, 13)];
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
    
    int messageCt = 0;
    for (Message *message in event.messages) {
        if(message.isViewed == NO) {
            messageCt++;
        }
    }
    if(messageCt > 0) {
        UIView *messageBackground = [[UIView alloc] initWithFrame:CGRectMake(54, 8, 22, 22)];
        messageBackground.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
        messageBackground.layer.cornerRadius = 11;
        messageBackground.tag = 1;
        [eventView addSubview:messageBackground];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        messageLabel.text = [NSString stringWithFormat:@"%i", messageCt];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageBackground addSubview:messageLabel];
    }

    int nameWidth = (int)(wd - (90 + (wd / 4)));
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, nameWidth, 20)];
    nameLabel.text = event.name;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [nameLabel sizeToFit];
    [eventView addSubview:nameLabel];
    
    int nameHeight = ceil(nameLabel.frame.size.height);
    
    UILabel *timeLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/5 - 10, 15, (wd*2)/5, 20)];
    [eventView addSubview:timeLabelContainer];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (wd*2)/5, 20)];
    timeLabel.text = event.localTime;
    timeLabel.textAlignment = NSTextAlignmentRight;
    [timeLabel setFont:[UIFont systemFontOfSize:18]];
    [timeLabelContainer addSubview:timeLabel];
    
    UIView *litView = [[UIView alloc] initWithFrame:CGRectMake((wd*3)/5 - 36, 30, (wd*2)/5, 40)];
    [eventView addSubview:litView];
    
    int goingCt = (int)event.going.count;
    if(goingCt > 4) {
        UIImageView *litImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd*2)/5, 0, 40, 40)];
        [litImageView setImage:[UIImage imageNamed:@"match"]];
        [litView addSubview:litImageView];
    }
    if(goingCt > 9) {
        UIImageView *litImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd*2)/5 - 22, 0, 40, 40)];
        [litImageView setImage:[UIImage imageNamed:@"match"]];
        [litView addSubview:litImageView];
    }
    if(goingCt > 19) {
        UIImageView *litImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd*2)/5 - 44, 0, 40, 40)];
        [litImageView setImage:[UIImage imageNamed:@"match"]];
        [litView addSubview:litImageView];
    }
    if(goingCt > 39) {
        UIImageView *litImageView = [[UIImageView alloc] initWithFrame:CGRectMake((wd*2)/5 - 66, 0, 40, 40)];
        [litImageView setImage:[UIImage imageNamed:@"match"]];
        [litView addSubview:litImageView];
    }
/*
//    int goingWd = (int)(wd*2)/5;
//    UIView *goingContainer = [[UIView alloc] initWithFrame:CGRectMake((wd*3)/5 - 10, 42, goingWd, 20)];
//    [eventView addSubview:goingContainer];
//    
//    UIImageView *goingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(goingWd - 60, 3, 14, 14)];
//    //NSString *goingImg = [NSString stringWithFormat:@"solidgrayface%d", (arc4random() % 8)];
//    [goingIcon setImage:[UIImage imageNamed:@"solidgraycheck"]];
//    [goingContainer addSubview:goingIcon];
//    
//    UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, goingWd - 62, 20)];
//    goingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)event.going.count];
//    goingLabel.textAlignment = NSTextAlignmentRight;
//    goingLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
//    [goingLabel setFont:[UIFont systemFontOfSize:18]];
//    [goingContainer addSubview:goingLabel];
//    
//    if(event.invited.count < 10) {
//        goingIcon.frame = CGRectMake(goingWd - 52, 3, 14, 14);
//        goingLabel.frame = CGRectMake(8, 0, goingWd - 62, 20);
//    }
//    
//    UIImageView *invitedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(goingWd - 16, 2, 16, 16)];
//    [invitedIcon setImage:[UIImage imageNamed:@"solidgrayinvited"]];
//    [goingContainer addSubview:invitedIcon];
//    
//    int invitedCt = 0;
//    for(EventGoing *person in event.invited)
//    {
//        if([person.facebookId isMemberOfClass:[NSNull class]] || person.facebookId.length == 0)
//            continue;
//        
//        BOOL isGoing = NO;
//        for(EventGoing *going in event.going)
//        {
//            if([going.userId isEqualToString:person.userId]) {
//                isGoing = YES;
//                break;
//            }
//        }
//        if(!isGoing)
//            invitedCt++;
//    }
//    
//    UILabel *invitedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, goingWd - 18, 20)];
//    invitedLabel.text = [NSString stringWithFormat:@"%i", invitedCt];
//    invitedLabel.textAlignment = NSTextAlignmentRight;
//    invitedLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
//    [invitedLabel setFont:[UIFont systemFontOfSize:18]];
//    [goingContainer addSubview:invitedLabel];
*/    
    
    int groupHeight = 0;
    if(![event.primaryGroupId isKindOfClass:[NSNull class]] && event.primaryGroupId.length > 0) {
        NSString *groupName = @"";
        for(int i = 0; i < [event.groupName componentsSeparatedByString: @"|"].count; i++) {
            NSString *groupId = [event.groupId componentsSeparatedByString: @"|"][i];
            if([groupId isEqualToString:event.primaryGroupId]) {
                groupName = [event.groupName componentsSeparatedByString: @"|"][i];
            }
        }
        groupHeight = 25;
        int top = eventView.frame.size.height - groupHeight;
        if(nameHeight + groupHeight + 30 > eventView.frame.size.height)
            top = nameHeight + groupHeight + 5;
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, wd, 20)];
        [groupLabel setText:groupName];
        groupLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
        [groupLabel setFont:[UIFont boldSystemFontOfSize:14]];
        groupLabel.textAlignment = NSTextAlignmentCenter;
        [eventView addSubview:groupLabel];
    }
    
//    if(![event.groupName isKindOfClass:[NSNull class]] && event.groupName.length > 0) {
//        NSString *groupText = @"";
//        NSArray *groups = [event.groupName componentsSeparatedByString: @"|"];
//        for (NSString *group in groups) {
//            groupText = [NSString stringWithFormat:@"%@ #%@", groupText, group];
//        }
//        
//        int groupWidth = (int)(wd - 80);
//        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, nameHeight + 20, groupWidth, 20)];
//        groupLabel.text = groupText;
//        groupLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
//        groupLabel.numberOfLines = 0;
//        groupLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        [groupLabel sizeToFit];
//        [eventView addSubview:groupLabel];
//        
//        groupHeight = ceil(groupLabel.frame.size.height);
//    }
    
    if(nameHeight + groupHeight + 30 > eventView.frame.size.height) {
        eventView.frame = CGRectMake(0, viewY, wd, nameHeight + groupHeight + 30);
    }
    
    
    return eventView;
}

-(void)eventClicked:(id)sender
{
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;

    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    NSArray *currentEvents = (NSArray *)[Session sessionVariables][@"currentEvents"];
    Event *event = (Event *)currentEvents[tagId];
    
    if(event.isPrivate) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private Event"
                                                        message:@"This event is private. Please join the interest to attend this event."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    [self openEvent:event];
    
    for(UIView *subview in button.subviews) {
        if(subview.tag == 1) {
            [subview removeFromSuperview];
        }
    }
}

-(void)goToEvent:(NSString *)eventId {
    [Event get:eventId completion:^(Event *event) {
        [self openEvent:event];
    }];
}

-(void)openEvent:(Event *)event {
    MFDetailView *detailView = [[MFDetailView alloc] init:event];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGPoint point = scrollView.contentOffset;
    if(point.y < -70)
    {
        [MFHelpers showProgressView:self.superview];
        MFView *view = (MFView *)self.superview;
        [view refresh];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.superview isMemberOfClass:[MFView class]])
    {
        MFView *view = (MFView *)self.superview;
        if (self.lastContentOffset > scrollView.contentOffset.y || scrollView.contentOffset.y < 30)
            [view scrollUp];
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            [view scrollDown];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

@end
