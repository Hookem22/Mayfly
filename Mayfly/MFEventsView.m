//
//  MFEventsView.m
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFEventsView.h"

@interface MFEventsView ()

@property (nonatomic, strong) NSMutableArray *Events;

@end

@implementation MFEventsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        self.delegate = self;
        self.Events = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadEvents
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [Event getBySchool:^(NSArray *events)
     {
         for(UIView *subview in self.subviews)
             [subview removeFromSuperview];
         
         self.Events = [events mutableCopy];
         
         int viewY = 0;
         for(int i = 0; i < [self.Events count]; i++)
         {
            Event *event = [self.Events objectAtIndex:i];

            bool newDay = i == 0;
            if(!newDay)
            {
                Event *prevEvent = [self.Events objectAtIndex:i - 1];
                if(prevEvent.dayOfWeek != event.dayOfWeek)
                    newDay = true;
            }
            if(newDay)
            {
                NSDate *today = [NSDate date];
                NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
                [myFormatter setDateFormat:@"EEEE"]; // day, like "Saturday"
                NSString *todayText = [myFormatter stringFromDate:today];
                
                NSArray *daysOfWeek = [NSArray arrayWithObjects: @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil ];
                NSString *dayText = [daysOfWeek objectAtIndex:event.dayOfWeek];
                if([todayText isEqualToString:dayText])
                    dayText = @"Today";
                else if([todayText isEqualToString:[daysOfWeek objectAtIndex:(event.dayOfWeek + 6) % 7]])
                    dayText = @"Tomorrow";
                
                UIControl *newDayView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
                [self addSubview:newDayView];
                //days++;
                
//                if(i > 0)
//                {
//                    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newDayView.frame.size.width, 1)];
//                    topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//                    topBorder.layer.shadowColor = [[UIColor blackColor] CGColor];
//                    topBorder.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//                    topBorder.layer.shadowRadius = 3.0f;
//                    topBorder.layer.shadowOpacity = 1.0f;
//                    [newDayView addSubview:topBorder];
//                }
                
                UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, newDayView.frame.size.height - 1.0f, newDayView.frame.size.width, 1)];
                bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
                [newDayView addSubview:bottomBorder];
                
                UIView *middleBorder = [[UIView alloc] initWithFrame:CGRectMake(20, newDayView.frame.size.height / 2, newDayView.frame.size.width - 40, 1)];
                middleBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
                [newDayView addSubview:middleBorder];
                
                UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 31, wd - 200, 20)];
                dayLabel.text = [NSString stringWithFormat:@"%@", dayText];
                dayLabel.textAlignment = NSTextAlignmentCenter;
                dayLabel.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
                [dayLabel setFont:[UIFont boldSystemFontOfSize:18]];
                [newDayView addSubview:dayLabel];
                
                viewY += 80;
            }
             
            UIView *eventView = [self addEventView:event viewY:viewY i:i];
            
            

//            CLLocation *loc = [[CLLocation alloc] initWithLatitude:event.location.latitude longitude:event.location.longitude];
//            CLLocationDistance distance = [currentLocation distanceFromLocation:loc];
//            double metersToMiles = 0.000621371;
//            double miles = distance * metersToMiles;
//            NSString *distanceText = @"";
//            if(miles < 1)
//             distanceText = @"< 1 mile away";
//            else if(miles < 1.5)
//             distanceText = @"1 mile away";
//            else
//             distanceText = [NSString stringWithFormat:@"%d miles away", (int)miles];

//            UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, wd, 20)];
//            distanceLabel.text = distanceText;
//            [eventView addSubview:distanceLabel];
            
             
//            if(event.isPrivate && !event.isGoing && !event.isInvited)
//            {
//                timeLabel.text = @"Private";
//            }
//            else
//            {
//                NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//                [outputFormatter setDateFormat:@"h:mm a"];
//                timeLabel.text = [outputFormatter stringFromDate:event.startTime];
//            }
//
//            if([event.going isMemberOfClass:[NSNull class]]) {
//                skip++;
//                continue;
//            }
//
//            NSArray *going = [event.going isEqualToString:@""] ? [[NSArray alloc] init] : [event.going componentsSeparatedByString:@"|"];
//            if(!event.isGoing && event.maxParticipants > 0 && [going count] >= event.maxParticipants) {
//                skip++;
//                continue;
//            }
            /*
            UILabel *manyLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/4, 40, (wd*2)/5, 20)];
            manyLabelContainer.textAlignment = NSTextAlignmentRight;
            [eventView addSubview:manyLabelContainer];
            */
//             NSString *manyText = @"";
//             if(event.maxParticipants > 0 && event.minParticipants > 1)
//                 manyText = [NSString stringWithFormat:@"Min: %lu Max: %lu", (unsigned long)event.minParticipants, (unsigned long)event.maxParticipants];
//             else if (event.minParticipants > 1)
//                 manyText = [NSString stringWithFormat:@"Min: %lu", (unsigned long)event.minParticipants];
//             else if(event.maxParticipants > 0)
//                 manyText = [NSString stringWithFormat:@"Max: %lu", (unsigned long)event.maxParticipants];
//             
//             
//            UILabel *manyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd - 20, 20)];
//            manyLabel.text = manyText;
//            manyLabel.textAlignment = NSTextAlignmentRight;
//            [eventView addSubview:manyLabel];


            UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, eventView.frame.size.height - 1.0f, eventView.frame.size.width, 1)];
            bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            [eventView addSubview:bottomBorder];

            [self addSubview:eventView];
             viewY += eventView.frame.size.height;
         }

         self.contentSize = CGSizeMake(wd, viewY + 120);
         
         if(self.contentSize.height < ht)
             self.contentSize = CGSizeMake(wd, ht - 40);
         
         [MFHelpers hideProgressView:self.superview];
     }];

}

-(UIView *)addEventView:(Event *)event viewY:(int)viewY i:(int)i {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
    [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
    eventView.backgroundColor = [UIColor whiteColor];
    eventView.tag = i;
    
    //Icon
    if([event.groupPictureUrl isKindOfClass:[NSNull class]] || event.groupPictureUrl.length <= 0) {
        NSString *iconImage = [NSString stringWithFormat:@"face%d", (arc4random() % 8)];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
        [icon setImage:[UIImage imageNamed:iconImage]];
        [eventView addSubview:icon];
    }
    else {
        MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(10, 10, 50, 50) url:event.groupPictureUrl];
        [eventView addSubview:pic];
    }
    
//    int nameWidth = (int)(wd - (70 + (wd / 4)));
//    UITextView *nameLabel = [[UITextView alloc] init];
//    nameLabel.text = [NSString stringWithFormat:@"%@", event.name];
//    [nameLabel setFont:[UIFont systemFontOfSize:18]];
//    int nameHeight = [MFHelpers heightForText:nameLabel width:nameWidth - 10];
//    nameLabel.frame = CGRectMake(70, 15, nameWidth, nameHeight);
//    nameLabel.scrollEnabled = NO;
//    [nameLabel setEditable:NO];
//    nameLabel.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    [nameLabel setUserInteractionEnabled:YES];
//    
//    UITapGestureRecognizer *gestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventNameClicked:)];
//    [nameLabel addGestureRecognizer:gestureRecognizer1];
//    nameLabel.tag = i;
//    
//    [eventView addSubview:nameLabel];

    int nameWidth = (int)(wd - (70 + (wd / 4)));
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, nameWidth, 20)];
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
    
    int groupHeight = 0;
    if(![event.groupName isKindOfClass:[NSNull class]] && event.groupName.length > 0) {
        NSString *groupText = @"";
        NSArray *groups = [event.groupName componentsSeparatedByString: @"|"];
        for (NSString *group in groups) {
            groupText = [NSString stringWithFormat:@"%@ #%@", groupText, group];
        }
        
        int groupWidth = (int)(wd - 80);
        UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, nameHeight + 20, groupWidth, 20)];
        groupLabel.text = groupText;
        groupLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
        groupLabel.numberOfLines = 0;
        groupLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [groupLabel sizeToFit];
        [eventView addSubview:groupLabel];
        
        groupHeight = ceil(nameLabel.frame.size.height);
    }
    
    if(nameHeight + groupHeight + 30 > eventView.frame.size.height) {
        eventView.frame = CGRectMake(0, viewY, wd, nameHeight + groupHeight + 30);
    }
    
    
    return eventView;
}

//-(NSArray *)reorderEvents:(NSArray *)events
//{
//    NSMutableArray *goingEvents = [[NSMutableArray alloc] init];
//    NSMutableArray *invitedEvents = [[NSMutableArray alloc] init];
//    NSMutableArray *otherEvents = [[NSMutableArray alloc] init];
//    
//    for(int i = 0; i < [events count]; i++)
//    {
//        Event *event = (Event *)[events objectAtIndex:i];
//        if(event.isGoing)
//            [goingEvents addObject:event];
//        else if(event.isInvited)
//            [invitedEvents addObject:event];
//        else
//            [otherEvents addObject:event];
//    }
//    
//    return [[goingEvents arrayByAddingObjectsFromArray:invitedEvents] arrayByAddingObjectsFromArray:otherEvents];
//}

-(void)loadUserEvents
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.facebookId == nil || [appDelegate.facebookId length] == 0)
        return;
    
    NSMutableArray *going = [[NSMutableArray alloc] init];
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    for(Event *event in self.Events)
    {
//        if([event.going rangeOfString:appDelegate.facebookId].location != NSNotFound)
//            [going addObject:event];
//        if([event.invited rangeOfString:appDelegate.facebookId].location != NSNotFound)
//            [invited addObject:event];
    }
    
    NSString *referenceId = (NSString *)[Session sessionVariables][@"referenceId"];
    
    if(referenceId != nil && [referenceId length] > 0)
    {
        [Event getByReferenceId:referenceId completion:^(Event *event){
            NSMutableArray *currentInvited = (NSMutableArray *)[Session sessionVariables][@"currentInvited"];
            if(currentInvited == nil)
                currentInvited = [[NSMutableArray alloc] init];
            
            [currentInvited addObject:event];
            [[Session sessionVariables] setObject:invited forKey:@"currentInvited"];
        }];
    }
    [[Session sessionVariables] setObject:going forKey:@"currentGoing"];
    [[Session sessionVariables] setObject:invited forKey:@"currentInvited"];
}

-(void)eventClicked:(id)sender
{
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;
    [self openEvent:tagId];
}

-(void)eventNameClicked:(UITapGestureRecognizer *)gesture{
    long tagId = gesture.view.tag;
    [self openEvent:tagId];
}

-(void)openEvent:(long)tagId {
    Event *event = (Event *)[self.Events objectAtIndex:tagId];
    //    if(event.isPrivate && !event.isInvited && ![FBSDKAccessToken currentAccessToken])
    //    {
    //        MFLoginView *loginView = [[MFLoginView alloc] init];
    //        [MFHelpers open:loginView onView:self.superview];
    //    }
    //    else if(event.isPrivate && !event.isGoing && !event.isInvited)
    //    {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Private Event"
    //                                                        message:@"You cannot join private events unless you are invited."
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
    //    else
    {
        MFDetailView *detailView = [[MFDetailView alloc] init:event.eventId];
        [MFHelpers open:detailView onView:self.superview];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGPoint point = scrollView.contentOffset;
    if(point.y < -70)
    {
        [MFHelpers showProgressView:self.superview];
        [self loadEvents];
    }
    

}

@end
