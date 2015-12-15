//
//  MFAddressBook.m
//  Mayfly
//
//  Created by Will Parks on 5/22/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFAddressBook.h"

@interface MFAddressBook ()

@property (nonatomic, strong) NSArray *friendList;
@property (nonatomic, strong) NSArray *contactList;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITextField *searchText;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSString *params;
@end

@implementation MFAddressBook

- (id)init:(NSArray *)invited
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initialize:invited];
        
    }
    return self;
}

-(id)initFromWebsite:(NSString *)params event:(Event *)event
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.params = params;
        self.event = event;
        NSMutableArray *invited = [[NSMutableArray alloc] init];
        if([params containsString:@"Invited%22:%22"] && [params containsString:@"Going%22:%22"])
        {
            NSRange invitedRange = [params rangeOfString:@"Invited%22:%22"];
            NSString *invitedString = [params substringFromIndex:invitedRange.location + invitedRange.length];
            invitedString = [invitedString substringToIndex:[invitedString rangeOfString:@"Going%22:%22"].location];
            
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSArray *people = [invitedString componentsSeparatedByString:@"%7C"];
            for(NSString *person in people)
            {
                NSString *info = [person componentsSeparatedByString:@":"][0];
                if(![info isEqualToString:appDelegate.facebookId])
                {
                    if([info hasPrefix:@"p"])
                        info = [[info substringFromIndex:1] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                    
                    NSDictionary *dict = @{@"id": info, @"Phone": info };
                    [invited addObject:dict];
                }
            }
        }
        [self initialize:invited];
    }
    return self;
}

+(NSString *)getContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    /*
    if (ABAddressBookRequestAccessWithCompletion) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    */
    if (accessGranted) {
        NSMutableArray *contacts = [[NSMutableArray alloc] init];
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        for (int i=0;i < nPeople;i++) {
            NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
            
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
            
            //For username and surname
            ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
            
            CFStringRef firstName, lastName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            
            NSString *sFirstName = (__bridge NSString *)firstName;
            NSString *sLastName = (__bridge NSString *)lastName;
            if(sFirstName == nil || [sFirstName isEqualToString:@"(null)"])
                sFirstName = @"";
            if(sLastName == nil || [sLastName isEqualToString:@"(null)"])
                sLastName = @"";
            if([sFirstName isEqualToString:@""] && [sLastName isEqualToString:@""])
                continue;
            
            NSString *name = [[NSString stringWithFormat:@"%@ %@", sFirstName, sLastName] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
            [dOfPerson setObject:name forKey:@"name"];
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", sFirstName] forKey:@"firstName"];
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", sLastName] forKey:@"lastName"];
            
            //For Phone number
            NSString* mobileLabel;
            
            for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                {
                    [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                }
                else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
                {
                    [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                    break ;
                }
                
            }
            if(![dOfPerson objectForKey:@"Phone"])
                continue;

            [contacts addObject:dOfPerson];
        }

        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
        contacts = [[contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];
        
        NSString *sContacts = @"";
        for(int i = 0; i < [contacts count]; i++)
        {
            NSDictionary *contact = [contacts objectAtIndex:i];
            sContacts = [NSString stringWithFormat:@"%@||%@|%@", sContacts, [contact objectForKey:@"Phone"], [contact objectForKey:@"name"]];
        }
        return sContacts;
    }
    
    
    return @"";
}

-(void)initialize:(NSArray *)invited
{
    [MFHelpers showProgressView:self];
    
    if([invited count] == 1 && [[invited objectAtIndex:0] isMemberOfClass:[Event class]])
        self.event = [invited objectAtIndex:0];

    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?fields=id,name,first_name" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSArray *fbList = [result objectForKey:@"data"];
                 NSMutableArray *friendList = [[NSMutableArray alloc] init];
                 for(int i = 0; i < [fbList count]; i++)
                 {
                     NSDictionary *dict = [fbList objectAtIndex:i];
                     NSMutableDictionary *friend = [[NSMutableDictionary alloc] init];
                     [friend setObject:[dict objectForKey:@"id"] forKey:@"id"];
                     [friend setObject:[dict objectForKey:@"name"] forKey:@"name"];
                     [friend setObject:[dict objectForKey:@"first_name"] forKey:@"firstName"];
                     [friend setObject:@"NO" forKey:@"invited"];
                     [friendList addObject:friend];
                     for(NSDictionary *contact in invited)
                     {
                         if(self.event == nil && [[contact objectForKey:@"id"] isEqualToString:[friend objectForKey:@"id"]])
                             [friend setObject:@"YES" forKey:@"invited"];
                     }
                 }
                 NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
                 self.friendList = [friendList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
             }
             
             [self loadAddressBook:invited];
         }];
    }
    else
    {
        [self loadAddressBook:invited];
    }
}

-(void)loadAddressBook:(NSArray *)invited
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = YES;
    /*
    if (ABAddressBookRequestAccessWithCompletion) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook invited:invited];
    }
    */
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook invited:invited];
    }
}

- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook invited:(NSArray *)invited {
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        NSString *sFirstName = (__bridge NSString *)firstName;
        NSString *sLastName = (__bridge NSString *)lastName;
        if(sFirstName == nil || [sFirstName isEqualToString:@"(null)"])
            sFirstName = @"";
        if(sLastName == nil || [sLastName isEqualToString:@"(null)"])
            sLastName = @"";
        if([sFirstName isEqualToString:@""] && [sLastName isEqualToString:@""])
            continue;
        
        NSString *name = [[NSString stringWithFormat:@"%@ %@", sFirstName, sLastName] stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        [dOfPerson setObject:name forKey:@"name"];
        [dOfPerson setObject:[NSString stringWithFormat:@"%@", sFirstName] forKey:@"firstName"];
        [dOfPerson setObject:[NSString stringWithFormat:@"%@", sLastName] forKey:@"lastName"];
        
        //For Email ids
        //ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        //if(ABMultiValueGetCount(eMail) > 0) {
        //    [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        //}
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        if(![dOfPerson objectForKey:@"Phone"])
            continue;
        
        NSString *isInvited = @"NO";
        for(NSDictionary *contact in invited)
        {
            if(self.event == nil && [[contact objectForKey:@"Phone"] isEqualToString:[dOfPerson objectForKey:@"Phone"]])
            {
                isInvited = @"YES";
                break;
            }
        }
        
        [dOfPerson setObject:isInvited forKey:@"invited"];
        [contacts addObject:dOfPerson];
        
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
    self.contactList = [contacts sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    //self.contactList = [contacts copy];
    
    //NSLog(@"Contacts = %@",self.contactList);
    [self setup:invited];
    
}

-(void)setup:(NSArray *)invited
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    if([invited count] == 0 || self.event != nil)
        headerLabel.text = @"Recipients";
    else
        headerLabel.text = [NSString stringWithFormat:@"Recipients (%lu)", (unsigned long)[invited count]];
    self.headerLabel = headerLabel;
    [self addSubview:self.headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 30, 80, 40);
    [self addSubview:cancelButton];
    
    if(self.event != nil)
    {
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Invite" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(inviteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.frame = CGRectMake(wd - 85, 30, 80, 40);
        [self addSubview:saveButton];
    }
    else
    {
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [saveButton setTitle:@"Add" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.frame = CGRectMake(wd - 85, 30, 80, 40);
        [self addSubview:saveButton];
    }
    UITextField *searchText = [[UITextField alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 30)];
    [searchText addTarget:self action:@selector(refresh) forControlEvents:UIControlEventEditingChanged];
    searchText.borderStyle = UITextBorderStyleRoundedRect;
    searchText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    searchText.font = [UIFont systemFontOfSize:15];
    searchText.placeholder = @"Search";
    self.searchText = searchText;
    [self addSubview:self.searchText];
    
    [self refresh];
}

-(void)refresh
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(id subview in self.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, wd, ht-110)];
    [self addSubview:scrollView];
    
    NSString *search = [self.searchText.text uppercaseString];
    
    //Friend List
    int skipCt = 0;
    int friendHt = 0;
    
    UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, wd, 30)];
    friendHeader.text = @"    Friends";
    friendHeader.textColor = [UIColor whiteColor];
    friendHeader.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:friendHeader];
    
    for(int i = 0; i < [self.friendList count]; i++)
    {
        NSMutableDictionary *contact = [self.friendList objectAtIndex:i];
        NSString *name = [contact objectForKey:@"name"];
        
        if(![search isEqualToString:@""] && ![[name uppercaseString] hasPrefix:search])
        {
            skipCt++;
            continue;
        }
        
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [nameButton setTitle:name forState:UIControlStateNormal];
        [nameButton addTarget:self action:@selector(nameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        nameButton.frame = CGRectMake(30, ((i - skipCt) * 30) + 40, wd - 60, 30);
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [nameButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        nameButton.tag = i;
        [scrollView addSubview:nameButton];
        
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            UIButton *invitedButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 100, 5, 20, 20)];
            [invitedButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            [nameButton addSubview:invitedButton];
        }
        
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nameButton.frame.size.height - 1.0f, nameButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [nameButton addSubview:bottomBorder];
        
        friendHt = ((i - skipCt) + 2) * 30;
    }
    
    //Contact List
    UILabel *contactHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 + friendHt, wd, 30)];
    contactHeader.text = @"    Address Book";
    contactHeader.textColor = [UIColor whiteColor];
    contactHeader.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:contactHeader];
    
    skipCt = 0;
    for(int i = 0; i < [self.contactList count]; i++)
    {
        NSMutableDictionary *contact = [self.contactList objectAtIndex:i];
        NSString *name = [contact objectForKey:@"name"];
        
        if(![search isEqualToString:@""])
        {
            NSString *firstName = [[contact objectForKey:@"firstName"] uppercaseString];
            NSString *lastName = [[contact objectForKey:@"lastName"] uppercaseString];
            
            if(![firstName hasPrefix:search] && ![lastName hasPrefix:search] && ![[name uppercaseString] hasPrefix:search])
            {
                skipCt++;
                continue;
            }
        }
        
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [nameButton setTitle:name forState:UIControlStateNormal];
        [nameButton addTarget:self action:@selector(nameButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        nameButton.frame = CGRectMake(30, ((i - skipCt) * 30) + 40 + friendHt, wd - 60, 30);
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [nameButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        nameButton.tag = i + 1000;
        [scrollView addSubview:nameButton];
        
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            UIButton *invitedButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 100, 5, 20, 20)];
            [invitedButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            [nameButton addSubview:invitedButton];
        }
        
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nameButton.frame.size.height - 1.0f, nameButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [nameButton addSubview:bottomBorder];
        
        scrollView.contentSize = CGSizeMake(wd, (((i - skipCt) + 4) * 30) + friendHt);
    }
    [MFHelpers hideProgressView:self];
}

-(void)nameButtonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *contact = [[NSDictionary alloc] init];
    if(button.tag < 1000)
    {
        contact = [self.friendList objectAtIndex:button.tag];
    }
    else
    {
        contact = [self.contactList objectAtIndex:button.tag - 1000];
    }
    NSString *invited = [contact objectForKey:@"invited"];
    if([invited isEqualToString:@"NO"])
    {
        [contact setValue:@"YES" forKey:@"invited"];
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        UIButton *invitedButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 100, 5, 20, 20)];
        [invitedButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [button addSubview:invitedButton];
    }
    else
    {
        [contact setValue:@"NO" forKey:@"invited"];
        for(UIView *subview in button.subviews) {
            if([subview isMemberOfClass:[UIButton class]])
               [subview removeFromSuperview];
        }
    }
    
    int invitedCt = 0;
    for(int i = 0; i < [self.friendList count]; i++)
    {
        contact = [self.friendList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            invitedCt++;
        }
    }
    for(int i = 0; i < [self.contactList count]; i++)
    {
        contact = [self.contactList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            invitedCt++;
        }
    }
    
    if(invitedCt == 0)
        self.headerLabel.text = @"Recipients";
    else
        self.headerLabel.text = [NSString stringWithFormat:@"Recipients (%d)", invitedCt];
}


-(void)cancelButtonClick:(id)sender
{
    [MFHelpers close:self];
}
-(void)saveButtonClick:(id)sender
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self.friendList count]; i++)
    {
        NSDictionary *contact = [self.friendList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            [contacts addObject:contact];
        }
    }
    for(int i = 0; i < [self.contactList count]; i++)
    {
        NSDictionary *contact = [self.contactList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            [contacts addObject:contact];
        }
    }
    
    if(self.params != nil && [self.params length] > 0)
    {
        if([self.params containsString:@"Invited%22:%22"] && [self.params containsString:@"%22,%22Going%22:%22"] && [contacts count] > 0)
        {
            NSRange invitedRange = [self.params rangeOfString:@"Invited%22:%22"];
            NSString *toInvitedString = [self.params substringToIndex:invitedRange.location + invitedRange.length];
            NSString *fromGoingString = [self.params substringFromIndex:[self.params rangeOfString:@"%22,%22Going%22:%22"].location];
            
            NSString *invitedString = @"";
            for(NSDictionary *contact in contacts)
            {
                NSString *fb = [contact valueForKey:@"id"];
                NSString *phone = [contact valueForKey:@"Phone"];
                NSString *firstName = [contact valueForKey:@"firstName"];
                if(fb != nil)
                    invitedString = [NSString stringWithFormat:@"%@%@:%@|", invitedString, fb, firstName];
                else if(phone != nil)
                    invitedString = [NSString stringWithFormat:@"%@p%@:%@|", invitedString, phone, firstName];
            }
            if([invitedString length] > 0)
                invitedString = [invitedString substringToIndex:[invitedString length] - 1];
            
            invitedString = [invitedString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            self.params = [NSString stringWithFormat:@"%@%@%@", toInvitedString, invitedString, fromGoingString];
            
            MFView *view = (MFView *)[self superview];
            [view returnAddressList:self.params];
        }
    }
    else
    {
        MFCreateView *createView = (MFCreateView *)[self superview];
        [createView invite:contacts];
    }

    [MFHelpers close:self];
}

-(void)inviteButtonClick:(id)sender
{
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
    NSString *pushMessageContacts = @"";
    for(int i = 0; i < [self.friendList count]; i++)
    {
        NSDictionary *contact = [self.friendList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            [contacts addObject:contact];
            
            NSString *fb = [contact valueForKey:@"id"];
            NSString *firstName = [contact valueForKey:@"firstName"];
            
            [facebookIds addObject:fb];
            pushMessageContacts = [NSString stringWithFormat:@"%@, %@", firstName, pushMessageContacts];
            
            //Add to invited
            NSString *person = [NSString stringWithFormat:@"%@:%@", fb, firstName];
            
            if([self.event.invited rangeOfString:fb].location == NSNotFound)
                self.event.invited = [self.event.invited length] <= 0 ? person : [NSString stringWithFormat:@"%@|%@", self.event.invited, person];
        }
    }
    if([contacts count] > 0)
    {
        ViewController *vc = (ViewController *)self.window.rootViewController;
        [self.event save:^(Event *event) {
            
            [vc.mainView goToEvent:event.referenceId];
            if([[self superview] isMemberOfClass:[MFDetailView class]])
            {
                MFDetailView *detailView = (MFDetailView *)[self superview];
                [detailView refreshGoing];
            }
        }];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [PushMessage inviteFriends:facebookIds from:appDelegate.name event:self.event];
        
        pushMessageContacts = [pushMessageContacts substringToIndex:[pushMessageContacts length] - 2];
        
        NSString *message = [NSString stringWithFormat:@"%@ have been invited to %@", pushMessageContacts, self.event.name];
        if([contacts count] == 1)
            message = [NSString stringWithFormat:@"%@ has been invited to %@", pushMessageContacts, self.event.name];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invites Sent"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self.contactList count]; i++)
    {
        NSDictionary *contact = [self.contactList objectAtIndex:i];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            NSString *phone = [contact valueForKey:@"Phone"];
            if(phone != nil)
            {
                [phoneNumbers addObject:phone];
                NSString *invitedPhone = [NSString stringWithFormat:@"p%@", phone];
                if([self.event.invited rangeOfString:invitedPhone].location == NSNotFound)
                    self.event.invited = [NSString stringWithFormat:@"%@|%@:%@", self.event.invited, invitedPhone, [contact valueForKey:@"firstName"]];
            }
        }
    }
    if([phoneNumbers count] > 0) {
        [[Session sessionVariables] setObject:self.event forKey:@"eventToSend"];
        [MFHelpers GetBranchUrl:self.event.referenceId eventName:self.event.name completion:^(NSString *url) {
            ViewController *vc = (ViewController *)self.window.rootViewController;
            [vc sendTextMessage:phoneNumbers message:url];
        }];
    }
    else
    {
        [MFHelpers close:self];
    }
}

@end
