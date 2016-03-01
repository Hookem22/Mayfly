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
@property (atomic, strong) UITextView *messageText;
@property (atomic, strong) UIImageView *imageView;

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
    viewY += 55;
    
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

-(void)postButtonClick:(id)sender
{
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

