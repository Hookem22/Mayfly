//
//  MFCreatePostView.m
//  Pow Wow
//
//  Created by Will Parks on 2/29/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFCreatePostView.h"

@interface MFCreatePostView()

@property (atomic, strong) UIScrollView *contentView;
@property (atomic, strong) UITextField *interestText;
@property (atomic, strong) UITextView *messageText;
@property (atomic, strong) UIImageView *imageView;
@property (atomic, strong) UIScrollView *interestView;
@property (atomic, strong) NSMutableArray *groups;
@property (atomic, strong) Group *selectedGroup;

@end

@implementation MFCreatePostView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

-(void)setup {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:singleTap];
    
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    [self addSubview:self.contentView];
    
    [MFHelpers addTitleBar:self titleText:@"New Post"];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeRight:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    int viewY = 20;
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    MFProfilePicView *postMessagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, viewY, 50, 50) facebookId:currentUser.facebookId];
    [self.contentView addSubview:postMessagePic];
    viewY += 15;
    
    UILabel *postMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, viewY, wd - 90, 20)];
    postMessageLabel.text = currentUser.firstName;
    [self.contentView addSubview:postMessageLabel];
    
    
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 56, viewY, 26, 20)];
    [imageButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:imageButton];
    viewY += 45;
    
    UITextField *interestText = [[UITextField alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 30)];
    [interestText addTarget:self action:@selector(openInterestSelect:) forControlEvents:UIControlEventEditingDidBegin];
    interestText.borderStyle = UITextBorderStyleRoundedRect;
    interestText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    interestText.font = [UIFont systemFontOfSize:15];
    interestText.placeholder = @"Post to Interest";
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    interestText.inputView = dummyView;
    self.interestText = interestText;
    [self.contentView addSubview:interestText];
    viewY += 40;
    
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 120)];
    [messageText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [messageText.layer setBorderWidth:1.0];
    [messageText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    messageText.font = [UIFont systemFontOfSize:15];
    messageText.layer.cornerRadius = 5;
    messageText.clipsToBounds = YES;
    self.messageText = messageText;
    [self.contentView addSubview:messageText];
    [messageText becomeFirstResponder];
    viewY += 130;
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 40)];
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    postButton.layer.cornerRadius = 20;
    postButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    [self.contentView addSubview:postButton];
}

-(void)openInterestSelect:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.interestView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    self.interestView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.interestView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeInterest)];
    [self.interestView addGestureRecognizer:singleTap];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    self.groups = [[NSMutableArray alloc] init];
    
    NSDictionary *stEdsDict = @{@"id": @"374D1035-CB60-4B44-9D1B-972834814ED6", @"name": @"St. Edward's Events", @"pictureurl": @"http://www.collegeatlas.org/wp-content/uploads/2014/04/st-edwards-university.gif" };
    Group *stEdsGroup = [[Group alloc] init:stEdsDict];
    [self.groups addObject:stEdsGroup];
    for(Group *group in currentUser.groups) {
        if(![group.groupId isEqualToString:@"374D1035-CB60-4B44-9D1B-972834814ED6"]) {
            [self.groups addObject:group];
        }
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(20, ht - (self.groups.count * 50) - 105, wd - 40, (self.groups.count * 50) + 40)];
    if((self.groups.count * 50) - 105 > ht) {
        backgroundView.frame = CGRectMake(20, 50, wd - 40, (self.groups.count * 50) + 40);
        self.interestView.contentSize = CGSizeMake(wd, (self.groups.count * 50) + 160);
    }
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 5.0;
    [self.interestView addSubview:backgroundView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, backgroundView.frame.size.width - 20, 20)];
    titleLabel.text = @"SELECT INTEREST";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:titleLabel];
    
    UIButton *questionButton = [[UIButton alloc] initWithFrame:CGRectMake(backgroundView.frame.size.width - 25, 10, 20, 20)];
    [questionButton setImage:[UIImage imageNamed:@"questionmark"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:questionButton];
    
    int viewY = 40;
    for (int i = 0; i < self.groups.count; i++) {
        Group *group = [self.groups objectAtIndex:i];
        UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(5, viewY, backgroundView.frame.size.width - 10, 50)];
        
        if([group.pictureUrl isKindOfClass:[NSNull class]] || group.pictureUrl.length <= 0) {
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
            [icon setImage:[UIImage imageNamed:@"group"]];
            [groupView addSubview:icon];
        }
        else {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(0, 5, 40, 40) url:group.pictureUrl];
            [groupView addSubview:pic];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(50, 0, backgroundView.frame.size.width - 60, 50);
        [button addTarget:self action:@selector(interestSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:group.name forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        button.tag = i;
        [groupView addSubview:button];
        
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, backgroundView.frame.size.width, 1)];
        border.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [groupView addSubview:border];
        
        [backgroundView addSubview:groupView];
        viewY += 50;
    }
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    int btnHt = backgroundView.frame.size.height > ht ? backgroundView.frame.size.height + 60 : (int)ht - 60;
    cancelButton.frame = CGRectMake(20, btnHt, wd - 40, 50);
    [cancelButton addTarget:self action:@selector(closeInterest) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    cancelButton.layer.cornerRadius = 5.0;
    [self.interestView addSubview:cancelButton];
}

-(void)interestSelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.selectedGroup = self.groups[button.tag];
    self.interestText.text = self.selectedGroup.name;
    [self closeInterest];
}

-(void)questionButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Interests"
                                                    message:@"What's up? Post what's going on around St. Edward's"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)postButtonClick:(id)sender
{
//    if(self.interestText.text.length == 0) {
//        self.interestText.layer.borderColor=[[UIColor redColor] CGColor];
//        self.interestText.layer.cornerRadius=8.0f;
//        self.interestText.layer.borderWidth= 1.0f;
//        return;
//    }
    
    if([self.messageText.text length] > 0 || self.imageView != nil)
    {
        [MFHelpers showDisableView:self];
        
        School *currentSchool = (School *)[Session sessionVariables][@"currentSchool"];
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        Post *post = [[Post alloc] init];
        post.userId = currentUser.userId;
        post.facebookId = currentUser.facebookId;
        post.name = currentUser.firstName;
        post.message = self.messageText.text;
        post.groupId = self.selectedGroup == nil ? @"" : self.selectedGroup.groupId;
        post.groupName = self.selectedGroup == nil ? @"" : self.selectedGroup.name;
        post.groupIsPublic = self.selectedGroup == nil ? YES : self.selectedGroup.isPublic;
        post.schoolId = currentSchool.schoolId;
        post.sentDate = [NSDate date];
        post.hasImage = self.imageView != nil;
        
        [post save:^(Post *newPost)
         {
             if(newPost.hasImage){
                 [newPost addImage:self.imageView.image completion:^(NSURL *url) {
                     [self refreshPosts:post];
                 }];
             }
             else {
                 [self refreshPosts:post];
             }
             
             //TODO: Add Notification
         }];
    }
    
    [self endEditing:YES];
}

-(void)refreshPosts:(Post *)post {
    post.secondsSince = 0;

    for(UIView *subview in self.superview.subviews) {
        if([subview isMemberOfClass:[MFPostsView class]]) {
            MFPostsView *postsView = (MFPostsView *)subview;
            [postsView addPost:post];
        }
    }
    
    [MFHelpers close:self];
}

- (void)imageButtonClick:(id)sender {
    ViewController *vc = (ViewController *)self.window.rootViewController;
    [vc selectMessagePhoto];
}

-(void)newImage:(UIImage *)img {
    [self endEditing:YES];
    
    float imgWd = self.messageText.frame.size.width;
    float imgHt = (imgWd / img.size.width) * img.size.height;
    
    self.imageView = [[UIImageView alloc] initWithImage:img];
    [self.imageView setFrame:CGRectMake(30, 330, imgWd, imgHt)];
    [self.contentView addSubview:self.imageView];
    self.contentView.contentSize = CGSizeMake(imgWd + 60, imgHt + 350);
}

-(void)closeInterest {
    [self.interestView removeFromSuperview];
    [self endEditing:YES];
}

-(void)dismissKeyboard:(id)sender {
    [self endEditing:YES];
}

-(void)closeRight:(id)sender
{
    [self endEditing:YES];
    [MFHelpers closeRight:self];
}

-(void)cancelButtonClick:(id)sender
{
    [self endEditing:YES];
    [MFHelpers close:self];
}

@end

