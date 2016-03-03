//
//  MFCreateCommentView.m
//  Pow Wow
//
//  Created by Will Parks on 3/2/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFCreateCommentView.h"
#import "MFPostDetailView.h"

@interface MFCreateCommentView()

@property (atomic, strong) UIScrollView *contentView;
@property (atomic, strong) UITextView *messageText;
@property (atomic, strong) Post *post;

@end

@implementation MFCreateCommentView

-(id)init:(Post *)post
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.post = post;
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
    
    [MFHelpers addTitleBar:self titleText:@"New Comment"];
    
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
    
// No Images on comments yet
//    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 56, viewY, 26, 20)];
//    [imageButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
//    [imageButton addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:imageButton];
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
    [postButton setTitle:@"Add Comment" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    postButton.layer.cornerRadius = 20;
    postButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    [self.contentView addSubview:postButton];
}

-(void)postButtonClick:(id)sender
{
    if([self.messageText.text length] > 0)
    {
        [MFHelpers showDisableView:self];
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        Comment *comment = [[Comment alloc] init];
        comment.postId = self.post.postId;
        comment.userId = currentUser.userId;
        comment.facebookId = currentUser.facebookId;
        comment.name = currentUser.firstName;
        comment.message = self.messageText.text;
        comment.sentDate = [NSDate date];
        comment.hasImage = NO;
        
        [comment save:^(Comment *newComment)
         {
             [self refreshPost:comment];
             
             [Post get:comment.postId completion:^(Post *post) {
                 NSString *msg = [NSString stringWithFormat:@"%@ commented on your post", comment.name];
                 NSString *info = [NSString stringWithFormat:@"Post|%@", comment.postId];
                 [PushMessage push:post.userId message:msg info:info];
                 
                 //TODO
                 //Notification *notification = [[Notification alloc] init: @{ @"userid": user.userId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"New Event: %@", event.name] }];
                 //[notification save:^(Notification *notification) { }];
             }];
         }];
    }

    [self endEditing:YES];
}

-(void)refreshPost:(Comment *)comment {
    comment.secondsSince = 0;
    
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    [comments addObject:comment];
    for(Comment *item in self.post.comments) {
        [comments addObject:item];
    }
    self.post.comments = comments;
    
    for(UIView *subview in self.superview.subviews) {
        if([subview isMemberOfClass:[MFPostDetailView class]]) {
            MFPostDetailView *postView = (MFPostDetailView *)subview;
            [postView setup];
        }
    }
    
    [MFHelpers close:self];
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


