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
@property (nonatomic, strong) UIView *pictureBackground;
@property (nonatomic, strong) UIImageView *pictureView;

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
    
    NSString *headerLabel = self.group ? @"Edit Interest" : @"Add Interest";
    [MFHelpers addTitleBar:self titleText:headerLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if([currentUser.facebookId isEqualToString:@"10106153174286280"] || [currentUser.facebookId isEqualToString:@"10106610968977054"]) {
        UIButton *stEdstn = [[UIButton alloc] initWithFrame:CGRectMake(wd - 40, 25, 30, 30)];
        [stEdstn setImage:[UIImage imageNamed:@"grayadd"] forState:UIControlStateNormal];
        [stEdstn addTarget:self action:@selector(switchToStEds:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stEdstn];
    }
    
    UIScrollView *createView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, wd, ht - 60)];
    self.createView = createView;
    [self addSubview:createView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [createView addGestureRecognizer:singleTap];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 20, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"Your Interest Name";
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
    passwordText.placeholder = @"Private Password";
    self.passwordText = passwordText;
    [createView addSubview:passwordText];
    
    self.pictureBackground = [[UIView alloc] initWithFrame:CGRectMake(90, 280, wd - 180, 80)];
    self.pictureBackground.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    self.pictureBackground.layer.cornerRadius = 5.0;
    [createView addSubview:self.pictureBackground];
    
    UIButton *pictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, wd - 180, 20)];
    [pictureButton setTitle:@"Add Picture" forState:UIControlStateNormal];
    pictureButton.titleLabel.textColor = [UIColor whiteColor];
    [pictureButton addTarget:self action:@selector(pictureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pictureBackground addSubview:pictureButton];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 60, wd, 2)];
    topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [createView addSubview:topBorder];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, createView.frame.size.height - 45, wd - 40, 40)];
    NSString *saveButtonTitle = self.group ? @"Save" : @"Create";
    [saveButton setTitle:saveButtonTitle forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    saveButton.layer.cornerRadius = 20;
    saveButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    [createView addSubview:saveButton];
    
    if(self.group) {
        self.nameText.text = self.group.name;
        if(self.group.description.length > 0) {
            self.descText.text = self.group.description;
            self.descText.textColor = [UIColor blackColor];
        }
        if(self.group.isPublic == false)
            [self.publicButton switchButton];
        if(self.group.password.length > 0)
            self.passwordText.text = self.group.password;
        
        if(self.group.hasImage || self.group.pictureUrl.length > 0)
        {
            self.pictureBackground.frame = CGRectMake(90, 360, wd - 180, 40);
            for(UIView *subview in self.pictureBackground.subviews) {
                if([subview isMemberOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)subview;
                    button.frame = CGRectMake(0, 10, wd - 180, 20);
                    [button setTitle:@"Change Picture" forState:UIControlStateNormal];
                }
            }
            
            self.pictureView = [[UIImageView alloc] initWithFrame:CGRectMake((wd - 70) / 2, 280, 70, 70)];
            dispatch_queue_t queue = dispatch_queue_create("Image Queue", NULL);
            dispatch_async(queue, ^{
                NSURL *nsurl = [NSURL URLWithString:self.group.pictureUrl];
                NSData *data = [NSData dataWithContentsOfURL:nsurl];
                UIImage *img = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pictureView setImage:img];
                    self.pictureView.layer.cornerRadius = 35.0;
                });
            });
            [self.createView addSubview:self.pictureView];
        }
    }
}

-(void)pictureButtonClick:(id)sender {
    ViewController *vc = (ViewController *)self.window.rootViewController;
    [vc selectMessagePhoto];
}

-(void)newImage:(UIImage *)image {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    self.pictureBackground.frame = CGRectMake(90, 360, wd - 180, 40);
    for(UIView *subview in self.pictureBackground.subviews) {
        if([subview isMemberOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.frame = CGRectMake(0, 10, wd - 180, 20);
            [button setTitle:@"Change Picture" forState:UIControlStateNormal];
        }
    }
    
    self.pictureView = [[UIImageView alloc] initWithFrame:CGRectMake((wd - 70) / 2, 280, 70, 70)];
    [self.pictureView setImage:image];
    self.pictureView.layer.cornerRadius = 35.0;
    [self.createView addSubview:self.pictureView];
}

-(void)saveButtonClick:(id)sender
{
    self.nameText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.passwordText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    
    if([self.nameText.text isEqualToString:@""])
    {
        self.nameText.layer.borderColor=[[UIColor redColor] CGColor];
        self.nameText.layer.cornerRadius=8.0f;
        self.nameText.layer.borderWidth= 1.0f;
        return;
    }
    if(!self.publicButton.isYes && self.passwordText.text.length == 0)
    {
        self.passwordText.layer.borderColor=[[UIColor redColor] CGColor];
        self.passwordText.layer.cornerRadius=8.0f;
        self.passwordText.layer.borderWidth= 1.0f;
        return;
    }
    
    Group *group = self.group == nil ? [[Group alloc] init] : self.group;
    group.name = self.nameText.text;
    group.description = [self.descText.text isEqualToString:@"Description"] ? @"" : self.descText.text;
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    group.schoolId = school.schoolId;
    group.latitude = school.latitude;
    group.longitude = school.longitude;
    
    group.isPublic = self.publicButton.isYes;
    group.password = self.passwordText.text;
    group.pictureUrl = @"";
    group.hasImage = self.pictureView != nil;
    
    [MFHelpers showDisableView:self];
    [group save:^(Group *group) {
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        [group addMember:currentUser.userId isAdmin:YES];
        
        if(self.pictureView != nil) {
            [group addImage:self.pictureView.image completion:^(Group *imgGroup) {
                [self finishSaving:imgGroup];
            }];
        }
        else {
            [self finishSaving:group];
        }
     }];
}

-(void)finishSaving:(Group *)group {

    for(id view in self.superview.subviews)
    {
        if([view isMemberOfClass:[MFGroupView class]])
        {
            MFGroupView *groupView = (MFGroupView *)view;
            [groupView addInterest:group];
        }
        else if([view isMemberOfClass:[MFGroupDetailView class]])
        {
            MFGroupDetailView *groupDetailView = (MFGroupDetailView *)view;
            [groupDetailView setup:group];
        }
    }
    [MFHelpers closeRight:self];
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

-(void)switchToStEds:(id)sender {
    Location *loc = (Location *)[Session sessionVariables][@"currentLocation"];
    if(loc.latitude < 1) {
        Location *location = [[Location alloc] init];
        location.latitude = 30.2290; //St. Edward's
        location.longitude = -97.7560;
        [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
        
        NSDictionary *schoolDict = @{@"id": @"E1668987-C219-484C-B5BB-1ACACDCADE17", @"name": @"St. Edward's", @"latitude": @"30.231", @"longitude": @"-97.758" };
        [[Session sessionVariables] setObject:[[School alloc] init: schoolDict] forKey:@"currentSchool"];
    }
    else {
        Location *location = [[Location alloc] init];
        location.latitude = 0.1; //Test
        location.longitude = 0.1;
        [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
        
        NSDictionary *schoolDict = @{@"id": @"32F991FE-15A0-4436-8CD2-C46413ABB1CA", @"name": @"Test School", @"latitude": @"0", @"longitude": @"0" };
        [[Session sessionVariables] setObject:[[School alloc] init: schoolDict] forKey:@"currentSchool"];
    }
    
    if([self.superview isMemberOfClass:[MFView class]])
    {
        MFView *view = (MFView *)self.superview;
        [view setup];
        [view refreshEvents];
    }
    [MFHelpers close:self];
}


@end
