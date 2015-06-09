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
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [Event get:^(NSArray *events)
     {
         self.Events = (NSMutableArray *)events;
         
         int skip = 0;
         for(int i = 0; i < [self.Events count]; i++)
         {
             Event *event = [self.Events objectAtIndex:i];
             UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, ((i - skip) * 80), wd, 80)];
             
             //UIButton *eventView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
             [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
             //eventView.frame = CGRectMake(0, (i * 80), wd, 80);
             eventView.tag = i;
             
             
             UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
             nameLabel.text = [NSString stringWithFormat:@"%@", event.name];
             [eventView addSubview:nameLabel];
             
             UILabel *timeLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/5, 40, (wd*2)/5, 20)];
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
             if([going count] >= event.maxParticipants) {
                 skip++;
                 continue;
             }
             UILabel *manyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, wd, 20)];
             manyLabel.text = [NSString stringWithFormat:@"%d out of %d people", [going count], event.maxParticipants];
             [eventView addSubview:manyLabel];
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, eventView.frame.size.height - 1.0f, eventView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
             [eventView addSubview:bottomBorder];
             
             [self addSubview:eventView];
             self.contentSize = CGSizeMake(wd, (((i - skip) + 1) * 80));
         }
         
         [self loadUserEvents];
     }];

}

-(void)loadUserEvents
{
    User *user = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *going = [[NSMutableArray alloc] init];
    NSMutableArray *invited = [[NSMutableArray alloc] init];
    for(Event *event in self.Events)
    {
        if([event.going rangeOfString:user.facebookId].location != NSNotFound)
            [going addObject:event];
        if([event.invited rangeOfString:user.facebookId].location != NSNotFound)
            [invited addObject:event];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFDetailView *detailView = [[MFDetailView alloc] initWithFrame:CGRectMake(0, ht, wd, ht - 120)];
    [detailView open:(Event *)[self.Events objectAtIndex:tagId]];
    [self.superview addSubview:detailView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         detailView.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

@end
