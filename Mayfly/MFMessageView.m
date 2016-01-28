//
//  MFMessageView.m
//  Mayfly
//
//  Created by Will Parks on 6/15/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFMessageView.h"

@interface MFMessageView ()

@property (atomic, strong) Event *event;
@property (atomic, strong) UIScrollView *messageView;
@property (atomic, strong) UIView *inputView;
@property (atomic, strong) UITextField *messageTextField;
@property (atomic, assign) NSInteger messageViewHeight;

@end

@implementation MFMessageView

-(id)init:(Event *)event
{
    self = [super init];
    if (self) {
        self.event = event;
        [self setup];
        [self populateMessages];
    }
    return self;
}

-(void)setup
{
    
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;

    self.backgroundColor = [UIColor whiteColor];

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = self.event.name;
    [self addSubview:headerLabel];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(15, 10, 80, 40);
    [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self addSubview:cancelButton];

    self.messageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 120)];
    [self addSubview:self.messageView];

    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, ht - 60, wd, 60)];
    [self addSubview:self.inputView];

    UIView *bottomBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 60)];
    bottomBackground.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self.inputView addSubview:bottomBackground];


    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
    bottomBorder.backgroundColor = [UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0];
    [self.inputView addSubview:bottomBorder];

    UITextField *messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, wd - 70, 30)];
    messageTextField.borderStyle = UITextBorderStyleRoundedRect;
    messageTextField.font = [UIFont systemFontOfSize:15];
    messageTextField.placeholder = @"Message";
    messageTextField.delegate = self;
    self.messageTextField = messageTextField;
    [self.inputView addSubview:messageTextField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    UISwipeGestureRecognizer *dismissKeyboard = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [dismissKeyboard setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [messageTextField addGestureRecognizer:dismissKeyboard];

    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(wd - 60, 10, 50, 30);
    [sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:sendButton];
}

-(void)sendMessage:(id)sender
{
    if([self.messageTextField.text length] > 0)
    {
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        Message *message = [[Message alloc] init];
        message.eventId = self.event.eventId;
        message.userId = currentUser.userId;
        message.facebookId = currentUser.facebookId;
        message.name = currentUser.firstName;
        message.message = self.messageTextField.text;
        message.sentDate = [NSDate date];
        
        [message save:^(Message *newMessage)
         {
             [self populateMessages];
             
             [PushMessage pushByEvent:self.event header:[NSString stringWithFormat:@"%@: %@", self.event.name, message.message] message:[NSString stringWithFormat: @"New Message|%@", message.eventId]];
         }];
        
        [self.messageTextField setText:@""];
    }
    
    [self endEditing:YES];
}

-(void)populateMessages
{
    [MFHelpers showProgressView:self.messageView];
    [Message get:self.event.eventId completion:^(NSArray *messages)
    {
        for(UIView *subview in self.messageView.subviews)
            [subview removeFromSuperview];
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        NSUInteger viewY = 0;
        for(int i = (int)[messages count] - 1; i >= 0; i--)
        {
            Message *message = (Message *)[messages objectAtIndex:i];
            
            bool isMe = [currentUser.userId isEqualToString:message.userId];
            NSString *userName = isMe ? @"" : message.name;
            UIView *view = [self addTextView:message.message from:userName date:[MFHelpers dateDiffBySeconds:message.secondsSince] isMe:isMe viewY:viewY];
            view.tag = 2;
            [self.messageView addSubview:view];
            viewY = viewY + view.frame.size.height;
        }
        
        self.messageViewHeight = viewY + 10;
        self.messageView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, self.messageViewHeight);
        
        if(viewY + 10 > [[UIScreen mainScreen] bounds].size.height - 120)
        {
            CGPoint bottomOffset = CGPointMake(0, self.messageView.contentSize.height - self.messageView.bounds.size.height);
            [self.messageView setContentOffset:bottomOffset animated:NO];
        }
        
        [MFHelpers hideProgressView:self.messageView];
    }];
}

-(UIView *)addTextView:(NSString *)message from:(NSString *)from date:(NSString *)date isMe:(BOOL)isMe viewY:(NSUInteger)viewY
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    if(isMe)
    {
        CGFloat textHeight = 0; //[MFHelpers heightForText:message width:(wd * 3) / 5 - 5 fontSize:14] + 10;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, textHeight + 25)];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake((wd * 2) / 5, 0, (wd * 3) / 5 - 10, 15)];
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.text = date;
        dateLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:dateLabel];
        
        UITextView *newTextbox = [[UITextView alloc] initWithFrame:CGRectMake((wd * 2) / 5, 18, (wd * 3) / 5 - 5, textHeight)];
        newTextbox.textColor = [UIColor whiteColor];
        newTextbox.font = [UIFont systemFontOfSize:14];
        newTextbox.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:128.0/255.0 blue:249.0/250.0 alpha:1.0];
        [newTextbox.layer setBorderColor:[[[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/250.0 alpha:1.0] colorWithAlphaComponent:1.0] CGColor]];
        [newTextbox.layer setBorderWidth:1.0];
        newTextbox.layer.cornerRadius = 15;
        newTextbox.clipsToBounds = YES;
        newTextbox.textContainerInset = UIEdgeInsetsMake(10, 8, 0, 0);
        newTextbox.text = message;
        
        [view addSubview:newTextbox];
        return view;
    }
    else
    {
        
        CGFloat textHeight = 0; //[MFHelpers heightForText:message width:(wd * 3) / 5 - 5 fontSize:14] + 10;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, viewY + 5, wd, textHeight + 25)];
        
        if(from.length > 0)
        {
            UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, wd - 5, 15)];
            fromLabel.font = [UIFont systemFontOfSize:12];
            fromLabel.text = [NSString stringWithFormat:@"%@ - %@", from, date];
            [view addSubview:fromLabel];
        }
        else
        {
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, wd - 5, 15)];
            dateLabel.font = [UIFont systemFontOfSize:12];
            dateLabel.text = date;
            [view addSubview:dateLabel];
        }
        
        UITextView *newTextbox = [[UITextView alloc] initWithFrame:CGRectMake(5, 18, (wd * 3) / 5 - 5, textHeight)];
        newTextbox.font = [UIFont systemFontOfSize:14];
        newTextbox.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/250.0 alpha:0.25];
        [newTextbox.layer setBorderColor:[[[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/250.0 alpha:1.0] colorWithAlphaComponent:1.0] CGColor]];
        [newTextbox.layer setBorderWidth:1.0];
        newTextbox.layer.cornerRadius = 15;
        newTextbox.clipsToBounds = YES;
        newTextbox.textContainerInset = UIEdgeInsetsMake(10, 8, 0, 0);
        newTextbox.text = message;
        
        [view addSubview:newTextbox];
        return view;
    }
}

-(void)dismissKeyboard
{
    self.messageView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, self.messageViewHeight);
    [self endEditing:YES];
}

-(void)cancelButtonClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MFHelpers closeRight:self];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self convertRect:keyboardRect fromView:nil];
    
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    self.messageView.contentSize = CGSizeMake(wd, self.messageViewHeight + keyboardRect.size.height);
    if(self.messageViewHeight + keyboardRect.size.height > ht - 120)
    {
        CGPoint bottomOffset = CGPointMake(0, self.messageView.contentSize.height - self.messageView.bounds.size.height);
        [self.messageView setContentOffset:bottomOffset animated:NO];
    }
    
    [UIView animateWithDuration:0.25 delay:0.005 options:0
                     animations:^{
                         self.inputView.frame = CGRectMake(0, ht - keyboardRect.size.height - 60, wd, 60);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.inputView.frame = CGRectMake(0, ht - 60, wd, 60);
                     }
                     completion:^(BOOL finished) {}];
}

@end
