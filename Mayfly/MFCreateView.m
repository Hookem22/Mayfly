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
    cancelButton.frame = CGRectMake(25, 40, 60, 20);
    [self addSubview:cancelButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(wd - 85, 40, 60, 20);
    [self addSubview:saveButton];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"Event Name";
    [self addSubview:nameText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 120, wd - 60, 100)];
    [descText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [descText.layer setBorderWidth:1.0];
    [descText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    descText.font = [UIFont systemFontOfSize:15];
    descText.layer.cornerRadius = 5;
    descText.clipsToBounds = YES;
    
    descText.delegate = self;
    descText.text = @"Details";
    descText.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    [self addSubview:descText];
    
    
    //TODO: Get location
    UITextField *locationText = [[UITextField alloc] initWithFrame:CGRectMake(30, 230, wd - 60, 30)];
    locationText.borderStyle = UITextBorderStyleRoundedRect;
    locationText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    locationText.font = [UIFont systemFontOfSize:15];
    locationText.placeholder = @"Location";
    [self addSubview:locationText];
    
    //TODO: Add clock
    UITextField *startText = [[UITextField alloc] initWithFrame:CGRectMake(30, 270, wd - 100, 30)];
    startText.borderStyle = UITextBorderStyleRoundedRect;
    startText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    startText.font = [UIFont systemFontOfSize:15];
    startText.placeholder = @"Start Time";
    [self addSubview:startText];
    
    UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 310, wd, 30)];
    participantsLabel.text = @"Participants";
    [self addSubview:participantsLabel];
    
    UITextField *minText = [[UITextField alloc] initWithFrame:CGRectMake((wd / 2), 310, (wd / 4) - 20, 30)];
    minText.borderStyle = UITextBorderStyleRoundedRect;
    minText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    minText.font = [UIFont systemFontOfSize:15];
    minText.placeholder = @"Min";
    [self addSubview:minText];
    
    UITextField *maxText = [[UITextField alloc] initWithFrame:CGRectMake((wd * 3) / 4 - 10, 310, (wd / 4) - 20, 30)];
    maxText.borderStyle = UITextBorderStyleRoundedRect;
    maxText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    maxText.font = [UIFont systemFontOfSize:15];
    maxText.placeholder = @"Max";
    [self addSubview:maxText];
    
    //TODO: Add IsPublic
    UILabel *isPublic = [[UILabel alloc] initWithFrame:CGRectMake(30, 340, wd-60, 30)];
    isPublic.text = @"Event is public";
    [self addSubview:isPublic];
    
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addFriendsButton.frame = CGRectMake(30, 380, wd-60, 30);
    [self addSubview:addFriendsButton];
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
        [self addSubview:loginView];
    }
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
