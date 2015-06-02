//
//  MFCreateView.m
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFCreateView.h"

@interface MFCreateView()

@property (nonatomic, strong) NSArray *contactsList;
@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextView *descText;
@property (nonatomic, strong) UITextField *locationText;
@property (nonatomic, strong) Location *location;
//TODO add isPrivate
@property (nonatomic, strong) UITextField *minText;
@property (nonatomic, strong) UITextField *maxText;
@property (nonatomic, strong) UITextField *startText;

@end

@implementation MFCreateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)create
{   
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"Create Event";
    [self addSubview:headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 30, 80, 40);
    [self addSubview:cancelButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(wd - 85, 30, 80, 40);
    [self addSubview:saveButton];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"Event Name";
    self.nameText = nameText;
    [self addSubview:nameText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 120, wd - 60, 80)];
    [descText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [descText.layer setBorderWidth:1.0];
    [descText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    descText.font = [UIFont systemFontOfSize:15];
    descText.layer.cornerRadius = 5;
    descText.clipsToBounds = YES;
    
    descText.delegate = self;
    descText.text = @"Details";
    descText.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    self.descText = descText;
    [self addSubview:descText];
    
    UITextField *startText = [[UITextField alloc] initWithFrame:CGRectMake(30, 210, wd - 60, 30)];
    [startText addTarget:self action:@selector(showClock:) forControlEvents:UIControlEventEditingDidBegin];
    [startText addTarget:self action:@selector(hideClock:) forControlEvents:UIControlEventEditingDidEnd];
    startText.borderStyle = UITextBorderStyleRoundedRect;
    startText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    startText.font = [UIFont systemFontOfSize:15];
    startText.placeholder = @"Start Time";
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    startText.inputView = dummyView;
    self.startText = startText;
    [self addSubview:startText];
    
    UITextField *locationText = [[UITextField alloc] initWithFrame:CGRectMake(30, 250, wd - 60, 30)];
    [locationText addTarget:self action:@selector(openLocationSelect:) forControlEvents:UIControlEventEditingDidBegin];
    locationText.borderStyle = UITextBorderStyleRoundedRect;
    locationText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    locationText.font = [UIFont systemFontOfSize:15];
    locationText.placeholder = @"Location";
    locationText.inputView = dummyView;
    self.locationText = locationText;
    [self addSubview:locationText];
    
    UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 290, wd, 30)];
    participantsLabel.text = @"Participants";
    participantsLabel.tag = 1;
    [self addSubview:participantsLabel];
    
    UITextField *minText = [[UITextField alloc] initWithFrame:CGRectMake((wd / 2), 290, (wd / 4) - 20, 30)];
    minText.borderStyle = UITextBorderStyleRoundedRect;
    minText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    minText.font = [UIFont systemFontOfSize:15];
    minText.placeholder = @"Min";
    minText.tag = 1;
    self.minText = minText;
    [self addSubview:minText];
    
    UITextField *maxText = [[UITextField alloc] initWithFrame:CGRectMake((wd * 3) / 4 - 10, 290, (wd / 4) - 20, 30)];
    maxText.borderStyle = UITextBorderStyleRoundedRect;
    maxText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    maxText.font = [UIFont systemFontOfSize:15];
    maxText.placeholder = @"Max";
    maxText.tag = 1;
    self.maxText = maxText;
    [self addSubview:maxText];
    
    //TODO: Add IsPublic
    UILabel *isPublic = [[UILabel alloc] initWithFrame:CGRectMake(30, 320, wd-60, 30)];
    isPublic.text = @"Event is public";
    isPublic.tag = 1;
    [self addSubview:isPublic];
    
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addFriendsButton.frame = CGRectMake(30, 360, wd-60, 30);
    addFriendsButton.tag = 1;
    [self addSubview:addFriendsButton];
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
        [self addSubview:loginView];
    }
}

-(void)showClock:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UIView *clockView = [[UIView alloc] initWithFrame:CGRectMake(0, ht, wd, 220)];
    clockView.tag = 2;
    [self addSubview:clockView];
    
    UIDatePicker  *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, wd, 200)];
    datePicker.datePickerMode = UIDatePickerModeTime;
    NSDate *in30min = [NSDate dateWithTimeIntervalSinceNow:30*60];
    [datePicker setDate:in30min];
    [datePicker addTarget:self action:@selector(didChangePickerDate:) forControlEvents:UIControlEventValueChanged];
    [clockView addSubview:datePicker];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         clockView.frame = CGRectMake(0, ht - 200, wd, 220);
                     }
                     completion:^(BOOL finished){
                         [self setStartDate:in30min];
                     }];
    
}

-(void)hideClock:(id)sender
{
    for(UIView *view in self.subviews)
    {
        if(view.tag == 2)
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
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    NSString *start = [outputFormatter stringFromDate:date];
    self.startText.text = start;
}

-(void)addFriendsButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFAddressBook *addressBook = [[MFAddressBook alloc] initWithFrame:CGRectMake(0, ht, wd, ht) invited:self.contactsList];
    [self addSubview:addressBook];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         addressBook.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)invite:(NSArray *)contactsList
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    self.contactsList = contactsList;
    NSString *people = [(NSDictionary *)[contactsList objectAtIndex:0] objectForKey:@"name"];
    for(int i = 1; i < [contactsList count]; i++)
    {
        NSDictionary *contact = [contactsList objectAtIndex:i];
        people = [NSString stringWithFormat:@"%@, %@", people, [contact objectForKey:@"name"]];
    }
    
    UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 420, wd - 60, 80)];
    participantsLabel.text = people;
    [self addSubview:participantsLabel];
}


-(void)cancelButtonClick:(id)sender
{
    [self close];
}
-(void)saveButtonClick:(id)sender
{
    Location *loc = [[Location alloc] init];
    
    Event *event = [[Event alloc] init];
    event.name = self.nameText.text;
    event.eventDescription = self.descText.text;
    event.location = self.location != nil ? self.location : [[Location alloc] init];
    event.minParticipants = [self.minText.text doubleValue];
    event.maxParticipants = [self.maxText.text doubleValue];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    event.startTime = [outputFormatter dateFromString:self.startText.text];
    
    NSTimeInterval plus30 = 30 * 60;
    event.cutoffTime = [event.startTime dateByAddingTimeInterval:plus30];
    
    [event save:^(Event *event)
     {
         NSLog(@"%@", event.eventId);
     }];
    
    if([self.contactsList count] > 0)
    {
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
        for(NSDictionary *contact in self.contactsList)
        {
            NSString *phone = [contact valueForKey:@"Phone"];
            if(phone != nil)
                [phoneNumbers addObject:phone];
        }
        ViewController *vc = (ViewController *)self.window.rootViewController;
        [vc sendTextMessage:phoneNumbers message:@"You have been invited to an event"];
    }
    else
    {
        [self close];
    }

}

-(void)openLocationSelect:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFLocationSelectView *locationView = [[MFLocationSelectView alloc] initWithFrame:CGRectMake(0, ht, wd, ht)];
    [self addSubview:locationView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         locationView.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)locationReturn:(Location *)location
{
    self.location = location;
    self.locationText.text = location.name;
    
    for (UIView *view in self.subviews)
    {
        if(view.tag == 1)
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + 170, view.frame.size.width, view.frame.size.height);
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    MFMapView *map = [[MFMapView alloc] initWithFrame:CGRectMake(30, 290, wd - 60, 160)];
    [map loadMap:location];
    [self addSubview:map];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Details"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Details";
        textView.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
    [textView resignFirstResponder];
}

-(void)close
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, ht, wd, ht - 60);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}
-(void)remove:(UIView *)view
{
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.frame = CGRectMake(0, ht, view.frame.size.width, view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

@end
