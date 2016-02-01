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
@property (nonatomic, strong) NSArray *groupsList;
@property (nonatomic, strong) NSArray *contactsList;
@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextView *descText;
@property (nonatomic, strong) MFLocationView *locationView;
@property (nonatomic, strong) MFPillButton *publicButton;
@property (nonatomic, strong) UITextField *minText;
@property (nonatomic, strong) UITextField *maxText;
@property (nonatomic, strong) MFClockView *startText;
@property (nonatomic, strong) UIButton *saveButton;

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
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer1];
    
    NSString *headerLabel = self.event ? @"Edit Event" : @"Create Event";
    [MFHelpers addTitleBar:self titleText:headerLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIScrollView *createView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, wd, ht - 60)];
    self.createView = createView;
    [self addSubview:createView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [createView addGestureRecognizer:singleTap];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 20, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"What do you want to do?";
    [nameText setReturnKeyType:UIReturnKeyDone];
    nameText.delegate = self;
    self.nameText = nameText;
    [createView addSubview:nameText];
    
    self.startText = [[MFClockView alloc] initWithFrame:CGRectMake(30, 60, wd - 60, 30) placeHolder:@"Start Time"];
    [createView addSubview:self.startText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 100, wd - 60, 80)];
    [descText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [descText.layer setBorderWidth:1.0];
    [descText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    descText.font = [UIFont systemFontOfSize:15];
    descText.layer.cornerRadius = 5;
    descText.clipsToBounds = YES;
    
    descText.delegate = self;
    descText.text = @"Location & Details";
    descText.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    self.descText = descText;
    [createView addSubview:descText];
    
    if(self.event)
    {
        nameText.text = self.event.name;
        if([self.event.description length]) {
            descText.text = self.event.description;
            descText.textColor = [UIColor blackColor];
        }
        [self.startText setTime:self.event.startTime];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton setTitle:@"Delete Event" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.frame = CGRectMake(20, 190, wd-40, 30);
        [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [createView addSubview:deleteButton];
        
    }
    else
    {
        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends or Groups" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(20, 190, wd-40, 30);
        [addFriendsButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [createView addSubview:addFriendsButton];
    }
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 60, wd, 2)];
    topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [createView addSubview:topBorder];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, createView.frame.size.height - 45, wd - 40, 40)];
    NSString *saveButtonTitle = self.event ? @"Save" : @"Create";
    [saveButton setTitle:saveButtonTitle forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    saveButton.layer.cornerRadius = 20;
    saveButton.layer.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
    self.saveButton = saveButton;
    [createView addSubview:saveButton];
}

-(void)addFriendsButtonClick:(id)sender
{
    MFAddressBook *addressBook = [[MFAddressBook alloc] init:self.contactsList];
    [MFHelpers open:addressBook onView:self];
    [self dismissKeyboard:nil];
}
-(void)invite:(NSArray *)contactsList
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(id subview in self.createView.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]])
            [subview removeFromSuperview];
    }
    
    UIScrollView *peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 235, wd, 80)];

    //Groups
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    int viewX = 0;
    for (Group *group in currentUser.groups) {
        if(group.isInvitedtoEvent) {
            [groups addObject:group];
            
            UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(viewX, 0, 60, 80)];
            
            if([group.pictureUrl isKindOfClass:[NSNull class]] || group.pictureUrl.length <= 0) {
                UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                [icon setImage:[UIImage imageNamed:@"group"]];
                [groupView addSubview:icon];
            }
            else {
                MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(0, 0, 50, 50) url:group.pictureUrl];
                [groupView addSubview:pic];
            }
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
            label.text = group.name;
            label.textAlignment = NSTextAlignmentCenter;
            [groupView addSubview:label];
            
            [peopleView addSubview:groupView];
            viewX += 60;
        }
    }
    self.groupsList = groups;
    
    //Contacts
    self.contactsList = contactsList;
    for(NSDictionary *contact in contactsList)
    {
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(viewX, 0, 60, 80)];
        
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
        viewX += 60;
    }
    viewX += 30;
    peopleView.contentSize = CGSizeMake(viewX, 80);
    peopleView.contentOffset = CGPointMake(-30, 0);
    [self.createView addSubview:peopleView];

}


-(void)cancelButtonClick:(id)sender
{
    [Group clearIsInvitedToEvent];
    [MFHelpers closeRight:self];
}
-(void)saveButtonClick:(id)sender
{
    //Validation
    self.nameText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.locationView.locationText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.startText.timeText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.minText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    
    BOOL error = false;
    if([self.nameText.text isEqualToString:@""])
    {
        self.nameText.layer.borderColor=[[UIColor redColor] CGColor];
        self.nameText.layer.cornerRadius=8.0f;
        self.nameText.layer.borderWidth= 1.0f;
        error = true;
    }
    if([self.startText.timeText.text isEqualToString:@""])
    {
        self.startText.timeText.layer.borderColor=[[UIColor redColor] CGColor];
        self.startText.timeText.layer.cornerRadius=8.0f;
        self.startText.timeText.layer.borderWidth= 1.0f;
        error = true;
    }
    if(error)
        return;
    
    
    Event *event = self.event == nil ? [[Event alloc] init] : self.event;
    event.name = self.nameText.text;
    event.description = [self.descText.text isEqualToString:@"Location & Details"] ? @"" : self.descText.text;
    event.location = self.locationView.location != nil ? self.locationView.location : [[Location alloc] init];
    event.minParticipants = [self.minText.text integerValue];
    event.maxParticipants = [self.maxText.text integerValue];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    event.location = [[Location alloc] init: @{ @"name": school.name, @"address": @"", @"latitude": [NSNumber numberWithInt:(int)school.latitude], @"longitude": [NSNumber numberWithInt:(int)school.longitude] }];
    event.schoolId = school.schoolId;
    
    event.startTime = self.startText.getTime;
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"c"];
    NSString *weekday = [dayFormatter stringFromDate:event.startTime];
    event.dayOfWeek = ([weekday intValue] + 6) % 7;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    event.localTime = [timeFormatter stringFromDate:event.startTime];
    
    //Don't schedule time earlier than now
    if ([event.startTime compare:[NSDate date]] == NSOrderedAscending) {
        self.startText.timeText.layer.borderColor=[[UIColor redColor] CGColor];
        self.startText.timeText.layer.cornerRadius=8.0f;
        self.startText.timeText.layer.borderWidth= 1.0f;
        return;
    }
    
    event.groupId = self.event == nil ? @"" : event.groupId;
    event.groupName = self.event == nil ? @"" : event.groupName;
    event.groupPictureUrl = self.event == nil ? @"" : event.groupPictureUrl;
    int privateCt = 0;
    for(Group *group in self.groupsList) {
        event.groupId = event.groupId.length == 0 ? group.groupId : [NSString stringWithFormat:@"%@|%@", event.groupId, group.groupId];
        event.groupName = event.groupName.length == 0 ? group.name : [NSString stringWithFormat:@"%@|%@", event.groupName, group.name];
        if(event.groupPictureUrl.length == 0 && group.pictureUrl.length > 0)
            event.groupPictureUrl = group.pictureUrl;
        if(group.isPublic == false)
            privateCt++;
    }
    event.groupIsPublic = privateCt == 0 || privateCt != self.groupsList.count;

    
    [self save:event];
    [Group clearIsInvitedToEvent];
}

-(void)save:(Event *)event
{
    [MFHelpers showProgressView:self];
    
    [event save:^(Event *event)
    {
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        [event addGoing:currentUser.userId isAdmin:YES];
        [MFHelpers hideProgressView:self];

         if(self.event)
         {
             if([self.superview isMemberOfClass:[MFDetailView class]])
             {
                 MFDetailView *detailView = (MFDetailView *)self.superview;
                 [detailView initialSetup:event];
                 
                 if([self.superview.superview isMemberOfClass:[MFView class]])
                 {
                     MFView *view = (MFView *)self.superview.superview;
                     [view refreshEvents];
                 }
             }

             [MFHelpers close:self];
             return;
         }
        
        [Group inviteGroups:self.groupsList event:self.event completion:^(NSDictionary *item) {}];
//         for(Group *group in self.groupsList) {
//            NSString *msg = [NSString stringWithFormat:@"New event in %@", group.name];
//            NSString *info = [NSString stringWithFormat:@"Invitation|%@", self.event.eventId];
//            [group sendMessageToGroup:msg info:info];
//         }
        
         Notification *notification = [[Notification alloc] init];
         notification.eventId = event.eventId;
         notification.userId = currentUser.userId;
         notification.message = [NSString stringWithFormat:@"Created: %@", event.name];
         [notification save:^(Notification *notification) { }];
        
         NSMutableArray *firstNames = [[NSMutableArray alloc] init];
         NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
         for(NSDictionary *contact in self.contactsList)
         {
             NSString *facebookId = [contact valueForKey:@"id"];
             NSString *phone = [contact valueForKey:@"Phone"];
             NSString *firstName = [contact valueForKey:@"firstName"];
             if(facebookId != nil) {
                 [event addInvite:facebookId name:firstName completion:^(EventGoing *eventGoing) {
                     
                 }];
             }
             if(phone != nil) {
                 [phoneNumbers addObject:phone];
                 [firstNames addObject:firstName];
             }
         }
        
         if([phoneNumbers count] > 0) {
             [[Session sessionVariables] setObject:event forKey:@"currentEvent"];
             [[Session sessionVariables] setObject:firstNames forKey:@"currentInvites"];
             
             [MFHelpers GetBranchUrl:event.referenceId eventName:event.name completion:^(NSString *url) {
                 ViewController *vc = (ViewController *)self.window.rootViewController;
                 [vc sendTextMessage:phoneNumbers message:url];
             }];
         }
         else
         {
             if([self.superview isMemberOfClass:[MFView class]])
             {
                 MFView *view = (MFView *)self.superview;
                 [view refreshEvents];
             }
             [MFHelpers close:self];
         }
     }];
}

-(void)deleteButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Event"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", self.event.name]
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //self.event.isPrivate = YES;
            break;
        case 1: //"Yes" pressed
            [self deleteEvent];
            break;
    }
}

-(void)deleteEvent{
    
    [MFHelpers showProgressView:self];
    [self.event deleteEvent:^(NSDictionary *item) {
        if([self.superview.superview isMemberOfClass:[MFView class]])
        {
            MFView *view = (MFView *)self.superview.superview;
            [view refreshEvents];
        }
        if([self.superview isMemberOfClass:[MFDetailView class]])
        {
            [self.superview removeFromSuperview];
        }
        
        [MFHelpers hideProgressView:self];
        [self cancelButtonClick:nil];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard:(id)sender
{
    [self endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Location & Details"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Location & Details";
        textView.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
    [textView resignFirstResponder];
}

-(void)nothing:(id)sender {
    
}



@end
