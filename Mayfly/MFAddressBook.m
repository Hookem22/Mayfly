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

@end

@implementation MFAddressBook

- (id)initWithFrame:(CGRect)frame invited:(NSArray *)invited
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        if ([FBSDKAccessToken currentAccessToken]) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?fields=id,name" parameters:nil]
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
                         [friend setObject:@"NO" forKey:@"invited"];
                         [friendList addObject:friend];
                         for(NSDictionary *contact in invited)
                         {
                             if([[contact objectForKey:@"id"] isEqualToString:[friend objectForKey:@"id"]])
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
    return self;
}

-(void)loadAddressBook:(NSArray *)invited
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
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
            if([[contact objectForKey:@"Phone"] isEqualToString:[dOfPerson objectForKey:@"Phone"]])
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
    if([invited count] == 0)
        headerLabel.text = @"Recipients";
    else
        headerLabel.text = [NSString stringWithFormat:@"Recipients (%lu)", (unsigned long)[invited count]];
    self.headerLabel = headerLabel;
    [self addSubview:self.headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 40, 60, 20);
    [self addSubview:cancelButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(wd - 85, 40, 60, 20);
    [self addSubview:saveButton];
    
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
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            name = [NSString stringWithFormat:@"%@ - Invited", name];
        }
        
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
        
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nameButton.frame.size.height - 1.0f, nameButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [nameButton addSubview:bottomBorder];
        
        friendHt = ((i - skipCt) + 2) * 30;
    }
    
    //Contact List
    UILabel *contactHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + friendHt, wd, 30)];
    contactHeader.text = @"    Address Book";
    contactHeader.textColor = [UIColor whiteColor];
    contactHeader.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:contactHeader];
    
    skipCt = 0;
    for(int i = 0; i < [self.contactList count]; i++)
    {
        NSMutableDictionary *contact = [self.contactList objectAtIndex:i];
        NSString *name = [contact objectForKey:@"name"];
        NSString *invited = [contact objectForKey:@"invited"];
        if(![invited isEqualToString:@"NO"]) {
            name = [NSString stringWithFormat:@"%@ - Invited", name];
        }
        //NSString *number = [contact objectForKey:@"Phone"];
        
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
        nameButton.frame = CGRectMake(30, ((i - skipCt) * 30) + 50 + friendHt, wd - 60, 30);
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [nameButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        nameButton.tag = i + 1000;
        [scrollView addSubview:nameButton];
        
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nameButton.frame.size.height - 1.0f, nameButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [nameButton addSubview:bottomBorder];
        
        scrollView.contentSize = CGSizeMake(wd, (((i - skipCt) + 4) * 30) + friendHt);
    }
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
        [button setTitle:[NSString stringWithFormat:@"%@ - Invited", [contact objectForKey:@"name"]] forState:UIControlStateNormal];
    }
    else
    {
        [contact setValue:@"NO" forKey:@"invited"];
        [button setTitle:[NSString stringWithFormat:@"%@", [contact objectForKey:@"name"]] forState:UIControlStateNormal];
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
    [self close];
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
    
    MFCreateView *createView = (MFCreateView *)[self superview];
    [createView invite:contacts];
    [self close];
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

@end
