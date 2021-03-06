//
//  MFClockView.m
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFClockView.h"
@interface MFClockView ()

@property (nonatomic, strong) NSDate *dateTime;

@end

@implementation MFClockView

@synthesize timeText = _timeText;

-(id)initWithFrame:(CGRect)frame placeHolder:(NSString *)placeHolder
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UITextField *timeText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [timeText addTarget:self action:@selector(showClock:) forControlEvents:UIControlEventEditingDidBegin];
        [timeText addTarget:self action:@selector(hideClock:) forControlEvents:UIControlEventEditingDidEnd];
        timeText.borderStyle = UITextBorderStyleRoundedRect;
        timeText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
        timeText.font = [UIFont systemFontOfSize:15];
        timeText.placeholder = placeHolder;
        UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        timeText.inputView = dummyView;
        self.timeText = timeText;
        [self addSubview:timeText];
        
        
    }
    return self;
}

-(NSDate *)getTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"MM-dd-yyyy h:mm a"];
    NSString *sDate = [outputFormatter stringFromDate:self.dateTime];
    NSDate *date = [outputFormatter dateFromString:sDate];
    return date;
}

-(void)setTime:(NSDate *)time
{
    self.dateTime = time;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEE MMM dd h:mm a"];
    self.timeText.text = [outputFormatter stringFromDate:time];
}

-(void)showClock:(id)sender
{
    NSUInteger wd = self.superview.frame.size.width;
    NSUInteger ht = self.superview.frame.size.height;
    
    UIView *clockView = [[UIView alloc] initWithFrame:CGRectMake(0, ht, wd, 220)];
    clockView.backgroundColor = [UIColor whiteColor];
    clockView.tag = 1001;
    [self.superview addSubview:clockView];
    
    UIDatePicker  *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, wd, 200)];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime; //UIDatePickerModeTime;
    //NSDate *in30min = [NSDate dateWithTimeIntervalSinceNow:30*60];
    //[datePicker setDate:in30min];
    [datePicker addTarget:self action:@selector(didChangePickerDate:) forControlEvents:UIControlEventValueChanged];
    [clockView addSubview:datePicker];

    if(![self.timeText.text isEqualToString:@""])
    {
        [datePicker setDate:[self getTime]];
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         clockView.frame = CGRectMake(0, ht - 200, wd, 220);
                     }
                     completion:^(BOOL finished){
                         //[self setStartDate:[NSDate date]];
                     }];
    
}

-(void)hideClock:(id)sender
{
    for(UIView *view in self.superview.subviews)
    {
        if(view.tag == 1001)
            [self remove:view];
    }
}

-(void)didChangePickerDate:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    [self setStartDate:datePicker.date];
}

-(void)setStartDate:(NSDate *)date
{
    self.dateTime = date;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEE MMM dd h:mm a"];
    
    NSString *start = [outputFormatter stringFromDate:date];
    self.timeText.text = start;
}

-(void)remove:(UIView *)view
{
    NSUInteger ht = self.superview.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, ht, view.frame.size.width, view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

@end
