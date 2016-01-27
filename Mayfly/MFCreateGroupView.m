//
//  MFCreateGroupView.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "MFCreateGroupView.h"

@interface MFCreateGroupView()

@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) UIScrollView *createView;
@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextView *descText;
@property (nonatomic, strong) MFPillButton *publicButton;
@property (nonatomic, strong) UITextField *passwordText;
@property (nonatomic, strong) UITextField *pictureUrlText;

@end

@implementation MFCreateGroupView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

-(id)init:(Group *)group
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.group = group;
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
    
    NSString *headerLabel = self.group ? @"Edit Group" : @"Create Group";
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
    nameText.placeholder = @"Your Group Name";
    [nameText setReturnKeyType:UIReturnKeyDone];
    nameText.delegate = self;
    self.nameText = nameText;
    [createView addSubview:nameText];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    UITextField *schoolText = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, wd - 60, 30)];
    schoolText.borderStyle = UITextBorderStyleRoundedRect;
    schoolText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    schoolText.font = [UIFont systemFontOfSize:15];
    [schoolText setText:school.name];
    schoolText.enabled = NO;
    [createView addSubview:schoolText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 100, wd - 60, 80)];
    [descText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [descText.layer setBorderWidth:1.0];
    [descText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    descText.font = [UIFont systemFontOfSize:15];
    descText.layer.cornerRadius = 5;
    descText.clipsToBounds = YES;
    
    descText.delegate = self;
    descText.text = @"Description";
    descText.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    self.descText = descText;
    [createView addSubview:descText];
    
    self.publicButton = [[MFPillButton alloc] initWithFrame:CGRectMake(30, 190, wd - 60, 40) yesText:@"Public" noText:@"Private"];
    [createView addSubview:self.publicButton];
    
    UITextField *passwordText = [[UITextField alloc] initWithFrame:CGRectMake(30, 240, wd - 60, 30)];
    passwordText.borderStyle = UITextBorderStyleRoundedRect;
    passwordText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    passwordText.font = [UIFont systemFontOfSize:15];
    passwordText.placeholder = @"Private Group Password";
    self.passwordText = passwordText;
    [createView addSubview:passwordText];
    
    UITextField *pictureUrlText = [[UITextField alloc] initWithFrame:CGRectMake(30, 280, wd - 60, 30)];
    pictureUrlText.borderStyle = UITextBorderStyleRoundedRect;
    pictureUrlText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    pictureUrlText.font = [UIFont systemFontOfSize:15];
    pictureUrlText.placeholder = @"Picture URL";
    self.pictureUrlText = pictureUrlText;
    [createView addSubview:pictureUrlText];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, createView.frame.size.height - 45, wd - 40, 40)];
    NSString *saveButtonTitle = self.group ? @"Save" : @"Create";
    [saveButton setTitle:saveButtonTitle forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    saveButton.layer.cornerRadius = 20;
    saveButton.layer.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
    [createView addSubview:saveButton];
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
        [self addSubview:loginView];
    }
}

-(void)saveButtonClick:(id)sender
{
    if([self.nameText.text isEqualToString:@""])
    {
        self.nameText.layer.borderColor=[[UIColor redColor] CGColor];
        self.nameText.layer.cornerRadius=8.0f;
        self.nameText.layer.borderWidth= 1.0f;
        return;
    }
    
    
    Group *group = self.group == nil ? [[Group alloc] init] : self.group;
    group.name = self.nameText.text;
    group.description = [self.descText.text isEqualToString:@"Desciption"] ? @"" : self.descText.text;
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    group.schoolId = school.schoolId;
    group.latitude = school.latitude;
    group.longitude = school.longitude;
    
    group.isPublic = self.publicButton.isYes;
    group.password = self.passwordText.text;
    group.pictureUrl = self.pictureUrlText.text;
    
    [MFHelpers showProgressView:self];
    [group save:^(Group *group) {
        [MFHelpers closeRight:self];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [group addMember:appDelegate.userId isAdmin:YES];
        
        for(id view in self.superview.subviews)
        {
            if([view isMemberOfClass:[MFGroupView class]])
            {
                MFGroupView *groupView = (MFGroupView *)view;
                [groupView loadGroups];
            }
        }
        [MFHelpers hideProgressView:self];
        
     }];
}

-(void)cancelButtonClick:(id)sender
{
    [MFHelpers closeRight:self];
}

-(void)dismissKeyboard:(id)sender
{
    [self endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Description"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Description";
        textView.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
    [textView resignFirstResponder];
}

@end