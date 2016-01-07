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

@property (nonatomic, strong) UIButton *groupButton;
@property (nonatomic, strong) UIButton *notificationButton;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation MFView

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    
    //NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    //NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    //UIImageView *launch = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    //[launch setImage:[UIImage imageNamed:@"launch1242x2208"]];
    //[self addSubview:launch];
    
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    MFEventsView *eventsView = [[MFEventsView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    [eventsView loadEvents];
    [self addSubview:eventsView];
    
    [MFHelpers addTitleBar:self titleText:@""];
    
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(90, 25, wd - 180, 30)];
    [header setImage:[UIImage imageNamed:@"title"]];
    [self addSubview:header];
    
    
   
//    self.notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 50, 25, 35, 30)];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    BOOL notify = appDelegate.hasNotifications || (NSString *)[Session sessionVariables][@"referenceId"] != nil;
//    NSString *imageName = notify ? @"bellNotify" : @"bell";
//    [self.notificationButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [self.notificationButton addTarget:self action:@selector(notificationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.notificationButton];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-80, 60, 60)];
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
    
    
    MFGroupView *groupView = [[MFGroupView alloc] init];
    groupView.frame = CGRectMake(wd, 60, wd, ht - 60);
    [groupView loadGroups];
    [self addSubview:groupView];
    
    self.groupButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 50, 25, 36, 36)];
    [self.groupButton setImage:[UIImage imageNamed:@"whitegroup"] forState:UIControlStateNormal];
    [self.groupButton addTarget:self action:@selector(groupButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.groupButton];
    
    UISwipeGestureRecognizer *groupRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openGroup)];
    [groupRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:groupRecognizer];
    
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

-(void)groupButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFGroupView class]])
        {
            MFGroupView *groupView = (MFGroupView *)subview;
            CGRect frame = CGRectMake(wd, 60, wd, ht- 60);
            if(groupView.frame.origin.x > 0)
                frame = CGRectMake(0, 60, wd, ht- 60);

            [UIView animateWithDuration:0.3
                             animations:^{
                                 groupView.frame = frame;
                             }
                             completion:^(BOOL finished){ }];
        }
    }
}

-(void)openGroup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFGroupView class]])
        {
            MFGroupView *groupView = (MFGroupView *)subview;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 groupView.frame = CGRectMake(0, 60, wd, ht- 60);
                             }
                             completion:^(BOOL finished){ }];
        }
    }
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
    NSUInteger referenceId = [[Session sessionVariables][@"referenceId"] integerValue];
    if(referenceId > 0)
    {
        [self joinEvent:referenceId];
        return;
    }
    
    [MFHelpers showProgressView:self];
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
    {
        if(![subview isKindOfClass:[UIImageView class]])
            [subview removeFromSuperview];
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
    [self.webView setScalesPageToFit:YES];
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    double lat = location == NULL ? 0 : location.latitude;
    double lng = location == NULL ? 0 : location.longitude;
    
    NSString *fbAccessToken = appDelegate.fbAccessToken == NULL ? @"" : appDelegate.fbAccessToken;
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&fbAccessToken=%@&deviceId=%@&pushDeviceToken=%@&lat=%f&lng=%f", fbAccessToken, uuid, uuid, lat, lng];
    NSLog(@"%@", urlAddress);
    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    
    [self addSubview:self.webView];
    [MFHelpers hideProgressView:self];
    
    /*
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 60, 200, 40)];
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    //loginButton.center = self.center;
    [self addSubview:loginButton];
     */
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:FacebookLogin"]) {
        
        [MFLoginView facebookLogin];
        
        return NO;
    }
    if ([[[request URL] absoluteString] hasPrefix:@"ios:GetContacts"]) {
        
        NSString *contacts = [[MFAddressBook getContacts] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *function = [NSString stringWithFormat:@"iOSContacts(\"%@\")", contacts];
        
        [self.webView stringByEvaluatingJavaScriptFromString:function];
        
        return NO;
    }
    /*
    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromCreate"]) {
        
        NSString *urlString = [[request URL] absoluteString];
        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
        
        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:nil];
        [MFHelpers open:addressBook onView:self];

        return NO;
    }
    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromDetails"]) {
        
        NSString *urlString = [[request URL] absoluteString];
        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
        NSRange eventParam = [params rangeOfString:@"&currentEvent="];
        NSString *eventUrl = [params substringFromIndex:eventParam.location + eventParam.length];
        
        Event *event = [[Event alloc] initFromUrl:eventUrl];
        
        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:event];
        [MFHelpers open:addressBook onView:self];
        
        return NO;
    }
    */
    if ([[[request URL] absoluteString] hasPrefix:@"ios:SendSMS"]) {
        
        NSString *urlString = [[request URL] absoluteString];
        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location + 1];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *keyValuePair in [params componentsSeparatedByString:@"&"])
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [dict setObject:value forKey:key];
        }

        ViewController *vc = (ViewController *)self.window.rootViewController;
        [vc sendTextMessage:[[dict objectForKey:@"phone"] componentsSeparatedByString:@","] message:[dict objectForKey:@"message"]];
        
        return NO;
    }
    
    return YES;
}

-(void)sendLatLngToWeb
{
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    if(location == NULL)
        return;
    
    NSString *function = [NSString stringWithFormat:@"ReceiveLocation(\"%f\",\"%f\")", location.latitude, location.longitude];    
    if(self.webView != NULL)
        [self.webView stringByEvaluatingJavaScriptFromString:function];
}

-(void)returnAddressList:(NSString *)params
{
        /*
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactList options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [self urlEncodeJSON:jsonString];
        params = [NSString stringWithFormat:@"%@&contactList=%@", params, jsonString];
        */
        NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/%@", params];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlAddress]];
        [self.webView loadRequest:requestObj];
}

-(void)goToEvent:(NSUInteger)referenceId
{
    if(self.webView == nil)
    {
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
        
        for(UIView *subview in self.subviews)
            [subview removeFromSuperview];
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
        [self.webView setScalesPageToFit:YES];
        self.webView.scrollView.bounces = NO;
        self.webView.delegate = self;
        [self addSubview:self.webView];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&goToEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
    BOOL toMessaging = [[Session sessionVariables][@"toMessaging"] boolValue];
    if(toMessaging)
        urlAddress = [NSString stringWithFormat:@"%@&toMessaging=true", urlAddress];
    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

    [self.webView loadRequest:requestObj];
}

-(void)joinEvent:(NSUInteger)referenceId
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    
    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&joinEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:requestObj];
}

-(NSString *)urlEncodeJSON:(NSString *)json;
{
    return [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.keyboardDisplayRequiresUserAction = NO;
    if(!webView.loading)
        [self sendLatLngToWeb];
}





@end
