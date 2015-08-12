//
//  MFView.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFView.h"
#import "ViewController.h"

@interface MFView ()

@property (nonatomic, strong) UIButton *notificationButton;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation MFView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wd, 80)];
    //headerLabel.text = @"Pow Wow";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
    [self addSubview:headerLabel];
    
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(90, 25, wd - 180, 30)];
    [header setImage:[UIImage imageNamed:@"title"]];
    [self addSubview:header];

    self.notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 50, 25, 35, 30)];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    BOOL notify = appDelegate.hasNotifications || (NSString *)[Session sessionVariables][@"referenceId"] != nil;
    NSString *imageName = notify ? @"bellNotify" : @"bell";
    [self.notificationButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.notificationButton addTarget:self action:@selector(notificationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.notificationButton];
    
    MFEventsView *eventsView = [[MFEventsView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    [eventsView loadEvents];
    [self addSubview:eventsView];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-80, 60, 60)];
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
    
    [MFHelpers showProgressView:self];
    
    /*
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
    */
    
    /*
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 60, 200, 40)];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    //loginButton.center = self.center;
    [self addSubview:loginButton];
    */
    
}

-(void)refreshEvents
{
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]])
        {
            MFEventsView *eventsView = (MFEventsView *)subview;
            [eventsView loadEvents];
        }
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate.hasNotifications) {
        [self.notificationButton setImage:[UIImage imageNamed:@"bellNotify"] forState:UIControlStateNormal];
        appDelegate.hasNotifications = NO;
    }
}


-(void) addButtonClick:(id)sender
{
    
    MFCreateView *createView = [[MFCreateView alloc] init];
    [MFHelpers open:createView onView:self];
    
    /*
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }*/
    /*
    NSMutableString *facebookRequest = [NSMutableString new];
    [facebookRequest appendString:@"/me/friends"];
    [facebookRequest appendString:@"?limit=100"];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:facebookRequest
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"fetched user:%@", result);
        }
    }];
    
    return;
    */
    
}

-(void)notificationButtonClick:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self];
        return;
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UIButton *notificationButton = (UIButton *)sender;
    [notificationButton setImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
    
    MFRightSideView *rightSideView;
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFRightSideView class]])
            rightSideView = (MFRightSideView *)subview;
    }
    if(rightSideView == nil)
    {
        MFRightSideView *rightSideView = [[MFRightSideView alloc] init];
        [self addSubview:rightSideView];
        
        rightSideView.frame = CGRectMake(wd, 60, (wd * 3) / 4, ht);
        
        [UIView animateWithDuration:0.3
                         animations:^{
                                 rightSideView.frame = CGRectMake(wd / 4, 60, (wd * 3) / 4, ht - 60);
                         }
                         completion:^(BOOL finished){ }];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             rightSideView.frame = CGRectMake(wd, 60, (wd * 3) / 4, ht - 60);
                         }
                         completion:^(BOOL finished){
                             [rightSideView removeFromSuperview];
                         }];
    }

}

-(void)openEvent:(NSString *)eventId toMessaging:(BOOL)toMessaging
{

     MFDetailView *detailView = [[MFDetailView alloc] init:eventId];
     [MFHelpers open:detailView onView:self.superview];
     
     if(toMessaging)
     {
         [Event get:^(Event *event)
          {
              MFMessageView *messageView = [[MFMessageView alloc] init:event];
              [MFHelpers open:messageView onView:detailView];
          }];
     }
}



//////////////////////
///// Website ////////
//////////////////////

-(void)loadWebsite
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
    [self.webView setScalesPageToFit:YES];
    
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://dev.joinpowwow.com/App/?OS=iOS&fbAccessToken=%@&lat=%f&lng=%f", appDelegate.fbAccessToken, location.latitude, location.longitude];
    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    
    [self.webView loadRequest:requestObj];
    
    [self addSubview:self.webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:AddressBookFromCreate"]) {
        
        NSString *urlString = [[request URL] absoluteString];
        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
        
        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params];  //[NSArray arrayWithObjects:self.event, nil]];
        [MFHelpers open:addressBook onView:self];


        
        // Call the given selector
        //[self performSelector:@selector(webToNativeCall)];
        // Cancel the location change
        return NO;
    }
    return YES;
    
}

-(void)returnAddressList:(NSString *)params
{
        /*
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactList options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [self urlEncodeJSON:jsonString];
        params = [NSString stringWithFormat:@"%@&contactList=%@", params, jsonString];
        */
        NSString *urlAddress = [NSString stringWithFormat:@"http://dev.joinpowwow.com/App/%@", params];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlAddress]];
        [self.webView loadRequest:requestObj];
}


-(NSString *)urlEncodeJSON:(NSString *)json;
{
    return [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}






@end
