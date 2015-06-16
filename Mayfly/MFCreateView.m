//
//  MFCreateView.m
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFCreateView.h"

@interface MFCreateView()

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) UIScrollView *createView;
@property (nonatomic, strong) NSArray *contactsList;
@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextView *descText;
@property (nonatomic, strong) MFLocationView *locationView;
@property (nonatomic, strong) MFPillButton *publicButton;
@property (nonatomic, strong) UITextField *minText;
@property (nonatomic, strong) UITextField *maxText;
@property (nonatomic, strong) MFClockView *startText;

@end

@implementation MFCreateView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

-(id)init:(Event *)event
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.event = event;
        [self setup];
    }
    return self;
}

-(void)setup
{   
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = self.event ? @"Edit Event" : @"Create Event";
    [self addSubview:headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(15, 20, 80, 40);
    [self addSubview:cancelButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *saveButtonTitle = self.event ? @"Save" : @"Create";
    [saveButton setTitle:saveButtonTitle forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(wd - 85, 20, 80, 40);
    [self addSubview:saveButton];
    
    UIScrollView *createView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, wd, ht - 60)];
    self.createView = createView;
    [self addSubview:createView];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 20, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"Event Name";
    self.nameText = nameText;
    [createView addSubview:nameText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 60, wd - 60, 80)];
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
    [createView addSubview:descText];
    
    self.locationView = [[MFLocationView alloc] initWithFrame:CGRectMake(30, 150, (wd * 3) / 5 - 35, 30) mapFrame:CGRectMake(30, 385, wd - 60, ht - 445)];
    [createView addSubview:self.locationView];
    
    self.startText = [[MFClockView alloc] initWithFrame:CGRectMake((wd * 3) / 5 + 5, 150, (wd * 2) / 5 - 35, 30) placeHolder:@"Start Time"];
    [createView addSubview:self.startText];
    
    UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 190, wd, 30)];
    participantsLabel.text = @"Other People:";
    [createView addSubview:participantsLabel];
    
    UITextField *minText = [[UITextField alloc] initWithFrame:CGRectMake((wd / 2), 190, (wd / 4) - 20, 30)];
    minText.borderStyle = UITextBorderStyleRoundedRect;
    minText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    minText.font = [UIFont systemFontOfSize:15];
    minText.placeholder = @"Min";
    self.minText = minText;
    [createView addSubview:minText];
    
    UITextField *maxText = [[UITextField alloc] initWithFrame:CGRectMake((wd * 3) / 4 - 10, 190, (wd / 4) - 20, 30)];
    maxText.borderStyle = UITextBorderStyleRoundedRect;
    maxText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    maxText.font = [UIFont systemFontOfSize:15];
    maxText.placeholder = @"Max";
    self.maxText = maxText;
    [createView addSubview:maxText];
    
    self.publicButton = [[MFPillButton alloc] initWithFrame:CGRectMake(30, 230, wd - 60, 40) yesText:@"Public" noText:@"Private"];
    [createView addSubview:self.publicButton];
    
    //TODO figure out if add friends on edit
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addFriendsButton.frame = CGRectMake(30, 275, wd-60, 30);
    [createView addSubview:addFriendsButton];
    
    if(self.event)
    {
        nameText.text = self.event.name;
        if([self.event.eventDescription length])
            descText.text = self.event.eventDescription;
        self.locationView.locationText.text = self.event.location.name;
        [self.startText setTime:self.event.startTime];
        minText.text = [NSString stringWithFormat:@"%d", self.event.minParticipants];
        if(self.event.minParticipants)
            maxText.text = [NSString stringWithFormat:@"%d", self.event.maxParticipants];
        
        //TODO figure out public button
    }
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
        [self addSubview:loginView];
    }
}

-(void)addFriendsButtonClick:(id)sender
{
    MFAddressBook *addressBook = [[MFAddressBook alloc] init:self.contactsList];
    [MFHelpers open:addressBook onView:self];
}
-(void)invite:(NSArray *)contactsList
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(id subview in self.createView.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]])
            [subview removeFromSuperview];
    }
    
    UIScrollView *peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 305, wd - 60, 80)];
    
    self.contactsList = contactsList;

    for(int i = 0; i < [contactsList count]; i++)
    {
        NSDictionary *contact = [contactsList objectAtIndex:i];
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(i * 60, 0, 60, 80)];
        
        NSString *facebookId = [contact objectForKey:@"id"];
        if(facebookId != nil)
        {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
            [personView addSubview:pic];
        }
        else
        {
            UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 60, 60)];
            int faceNumber = (arc4random() % 8);
            [pic setImage:[UIImage imageNamed:[NSString stringWithFormat:@"face%d", faceNumber]]];
            [personView addSubview:pic];
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
        label.text = [contact objectForKey:@"firstName"];
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [peopleView addSubview:personView];
        peopleView.contentSize = CGSizeMake((i + 1) * 60, 80);
    }
    
    [self.createView addSubview:peopleView];

}


-(void)cancelButtonClick:(id)sender
{
    [MFHelpers close:self];
}
-(void)saveButtonClick:(id)sender
{
    //TODO figure out save on edit
    
    [MFHelpers showProgressView:self];
    
    Event *event = [[Event alloc] init];
    event.name = self.nameText.text;
    event.eventDescription = [self.descText.text isEqualToString:@"Details"] ? @"" : self.descText.text;
    event.location = self.locationView.location != nil ? self.locationView.location : [[Location alloc] init];
    event.minParticipants = [self.minText.text integerValue] + 1;
    event.maxParticipants = [self.maxText.text integerValue];
    if(event.maxParticipants > 0)
        event.maxParticipants++;
    
    NSDate *time = self.startText.getTime;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *timeComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:time];
    [components setHour:timeComponents.hour];
    [components setMinute:timeComponents.minute];
    event.startTime = [calendar dateFromComponents:components];
    
    NSTimeInterval minus30 = -30 * 60;
    event.cutoffTime = [event.startTime dateByAddingTimeInterval:minus30];
    
    event.isPrivate = !self.publicButton.isYes; //isYes == Public
    
    event.invited = @"";
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    event.going = [NSString stringWithFormat:@"%@:%@", appDelegate.facebookId, appDelegate.firstName];

    event.referenceId = 0;
    
    //TODO: Validation
    
    
    if([self.contactsList count] > 0)
    {
        NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
        for(NSDictionary *contact in self.contactsList)
        {
            NSString *fb = [contact valueForKey:@"id"];
            if(fb != nil)
            {
                [facebookIds addObject:fb];
                if([event.invited length] <= 0)
                    event.invited = fb;
                else
                    event.invited = [NSString stringWithFormat:@"%@|%@", event.invited, fb];
            }
        }
        if([facebookIds count] > 0)
            [PushMessage inviteFriends:facebookIds from:appDelegate.name message:event.name];
    }
    
    [event save:^(Event *event)
     {
         [MFHelpers hideProgressView:self];
         
         NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
         for(NSDictionary *contact in self.contactsList)
         {
             NSString *phone = [contact valueForKey:@"Phone"];
             if(phone != nil)
                 [phoneNumbers addObject:phone];
         }
         if([phoneNumbers count] > 0) {
             ViewController *vc = (ViewController *)self.window.rootViewController;
             [vc sendTextMessage:phoneNumbers message:[NSString stringWithFormat:@"You have been invited to: %@. Download the app here: http://getmayfly.com?%lu", event.name, (unsigned long)event.referenceId]];
         }
        else
        {
            MFView *view = (MFView *)[self superview];
            [view setup];
            [MFHelpers close:self];
        }
     }];

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



@end
