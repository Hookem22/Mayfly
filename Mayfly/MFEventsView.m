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
         for(Event *ev in events)
         {
             NSLog(@"%@", ev);
         }
     }];
    
    //NSMutableArray *events = [[NSMutableArray alloc] init];
    NSDictionary *dict1 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Disc?",@"name",
                           @"We will be meeting at Zilker at 3pm to play disc. Please RSVP if you want to attend. Blah blah blah. Blah blah blah. Blah blah blah. Blah blah blah. ", @"eventDescription",
                           nil];
    NSDictionary *dict2 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Monopoly?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict3 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Tennis?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict4 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Soccer?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict5 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Disc?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict6 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Who wants to play monpoly tonight?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict7 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Tennis?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    NSDictionary *dict8 = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"Soccer?",@"name",
                           @"Desc", @"eventDescription",
                           nil];
    [self.Events addObject:[[Event alloc]init:dict1]];
    [self.Events addObject:[[Event alloc]init:dict2]];
    [self.Events addObject:[[Event alloc]init:dict3]];
    [self.Events addObject:[[Event alloc]init:dict4]];
    [self.Events addObject:[[Event alloc]init:dict5]];
    [self.Events addObject:[[Event alloc]init:dict6]];
    [self.Events addObject:[[Event alloc]init:dict7]];
    [self.Events addObject:[[Event alloc]init:dict8]];
    
    for(int i = 0; i < [self.Events count]; i++)
    {
        Event *event = [self.Events objectAtIndex:i];
        
        UIControl *eventView = [[UIControl alloc] initWithFrame:CGRectMake(0, (i * 80), wd, 80)];
        
        //UIButton *eventView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [eventView addTarget:self action:@selector(eventClicked:) forControlEvents:UIControlEventTouchUpInside];
        //eventView.frame = CGRectMake(0, (i * 80), wd, 80);
        eventView.tag = i;
        [self addSubview:eventView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, wd, 20)];
        nameLabel.text = [NSString stringWithFormat:@"%@", event.name];
        [eventView addSubview:nameLabel];
        
        UILabel *timeLabelContainer = [[UILabel alloc] initWithFrame:CGRectMake((wd*3)/5, 40, (wd*2)/5, 20)];
        timeLabelContainer.textAlignment = NSTextAlignmentRight;
        [eventView addSubview:timeLabelContainer];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeLabelContainer.frame.size.width, 20)];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.text = [NSString stringWithFormat:@"%d minutes left", (i + 1) * 5];
        [timeLabelContainer addSubview:timeLabel];
        
        UILabel *manyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, wd, 20)];
        //manyLabel.textAlignment = NSTextAlignmentCenter;
        manyLabel.text = [NSString stringWithFormat:@"%d out of 10 members", 9 - i];
        [eventView addSubview:manyLabel];
        
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, eventView.frame.size.height - 1.0f, eventView.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [eventView addSubview:bottomBorder];
        
        self.contentSize = CGSizeMake(wd, ((i + 1) * 80));
    }
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
