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
        self.backgroundColor = [UIColor whiteColor];
        self.Events = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadEvents
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    [Event get:^(NSArray *events)
     {        
         for(UIView *subview in self.subviews)
             [subview removeFromSuperview];
         
         self.Events = (NSMutableArray *)events;
         
         Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
         CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
         
         int skip = 0;
         for(int i = 0; i < [self.Events count]; i++)
         {
             Event *event = [self.Events objectAtIndex:i];
             UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, ((i - skip) * 80), wd, 80)];
             [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
             eventView.tag = i;
             
             UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
             nameLabel.text = [NSString stringWithFormat:@"%@", event.name];
             nameLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
             [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [eventView addSubview:nameLabel];
             
             CLLocation *loc = [[CLLocation alloc] initWithLatitude:event.location.latitude longitude:event.location.longitude];
             CLLocationDistance distance = [currentLocation distanceFromLocation:loc];
             double metersToMiles = 0.000621371;
             double miles = distance * metersToMiles;
             NSString *distanceText = @"";
             if(miles < 1)
                 distanceText = @"< 1 mile away";
             else if(miles < 1.5)
                 distanceText = @"1 mile away";
             else
                 distanceText = [NSString stringWithFormat:@"%d miles away", (int)miles];
             
             UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, wd, 20)];
             distanceLabel.text = distanceText;
             [eventView addSubview:distanceLabel];
             
             UILabel *timeLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/4, 10, (wd*2)/5, 20)];
             timeLabelContainer.textAlignment = NSTextAlignmentRight;
             [eventView addSubview:timeLabelContainer];
             
             UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeLabelContainer.frame.size.width, 20)];
             timeLabel.textAlignment = NSTextAlignmentLeft;
             
             NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
             [outputFormatter setDateFormat:@"h:mm a"];
             timeLabel.text = [outputFormatter stringFromDate:event.startTime];
             [timeLabelContainer addSubview:timeLabel];
             
             if([event.going isMemberOfClass:[NSNull class]]) {
                 skip++;
                 continue;
             }
             
             NSArray *going = [event.going isEqualToString:@""] ? [[NSArray alloc] init] : [event.going componentsSeparatedByString:@"|"];
             if(event.maxParticipants > 0 && [going count] >= event.maxParticipants) {
                 skip++;
                 continue;
             }
             UILabel *manyLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/4, 40, (wd*2)/5, 20)];
             manyLabelContainer.textAlignment = NSTextAlignmentRight;
             [eventView addSubview:manyLabelContainer];
             
             UILabel *manyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeLabelContainer.frame.size.width, 20)];
             manyLabel.text = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)[going count], (unsigned long)event.minParticipants];
             manyLabel.textAlignment = NSTextAlignmentLeft;
             [manyLabelContainer addSubview:manyLabel];
             
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, eventView.frame.size.height - 1.0f, eventView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
             [eventView addSubview:bottomBorder];
             
             [self addSubview:eventView];
             self.contentSize = CGSizeMake(wd, (((i - skip) + 1) * 80));
         }

         [MFHelpers hideProgressView:self.superview];
     }];

}

-(void)loadUserEvents
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.facebookId == nil || [appDelegate.facebookId length] == 0)
        return;
    
    NSMutableArray *going = [[NSMutableArray alloc] init];
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    for(Event *event in self.Events)
    {
        if([event.going rangeOfString:appDelegate.facebookId].location != NSNotFound)
            [going addObject:event];
        if([event.invited rangeOfString:appDelegate.facebookId].location != NSNotFound)
            [invited addObject:event];
    }
    
    NSString *referenceId = appDelegate.referenceId;
    
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

-(void) eventClicked:(id)sender
{
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;
    
    MFDetailView *detailView = [[MFDetailView alloc] init:(Event *)[self.Events objectAtIndex:tagId]];
    [MFHelpers open:detailView onView:self.superview];
    
}

@end
