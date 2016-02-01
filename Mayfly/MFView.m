//
//  MFView.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFView.h"
#import "ViewController.h"

//@interface MFView ()
//
//@property (nonatomic, strong) UIButton *groupButton;
//@property (nonatomic, strong) UIButton *notificationButton;
//@property (nonatomic, strong) UIWebView *webView;
//
//@end

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
    
    MFEventsView *eventsView = [[MFEventsView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    //[eventsView loadEvents];
    [self addSubview:eventsView];
    
    [MFHelpers addTitleBar:self titleText:@""];
    
    UIButton *stEdsButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 25, wd - 180, 30)];
    [stEdsButton setImage:[UIImage imageNamed:@"title"] forState:UIControlStateNormal];
    [stEdsButton addTarget:self action:@selector(switchToStEds:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:stEdsButton];

    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((wd / 2) - 30, ht-80, 60, 60)];
    [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addButton];
    
    MFNotificationView *notificationView = [[MFNotificationView alloc] init];
    notificationView.frame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
    [self addSubview:notificationView];
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 32, 28, 18)];
    [menuButton setImage:[UIImage imageNamed:@"whiteMenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuButton];
    
    UISwipeGestureRecognizer *menuRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(menuButtonClick:)];
    [menuRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:menuRecognizer];
    
    
    MFGroupView *groupView = [[MFGroupView alloc] init];
    groupView.frame = CGRectMake(wd, 60, wd, ht - 60);
    [groupView loadGroups];
    [self addSubview:groupView];
    
    UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 50, 25, 36, 36)];
    [groupButton setImage:[UIImage imageNamed:@"whitegroup"] forState:UIControlStateNormal];
    [groupButton addTarget:self action:@selector(groupButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:groupButton];
    
    UISwipeGestureRecognizer *groupRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(groupButtonClick:)];
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
}


-(void) addButtonClick:(id)sender
{
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self];
        return;
    }
    
    MFCreateView *createView = [[MFCreateView alloc] init];
    [MFHelpers open:createView onView:self];
    
}

-(void)groupButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFNotificationView *notificationView;
    MFGroupView *groupView;
    MFEventsView *eventsView;
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFNotificationView class]])
            notificationView = (MFNotificationView *)subview;
        else if([subview isMemberOfClass:[MFGroupView class]])
            groupView = (MFGroupView *)subview;
        else if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
    }
    
    CGRect notificationFrame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
    CGRect groupFrame = CGRectMake(wd, 60, wd, ht- 60);
    CGRect eventFrame = CGRectMake(0, 60, wd, ht - 60);
    if(groupView.frame.origin.x > 0) {
        groupFrame = CGRectMake(0, 60, wd, ht- 60);
        eventFrame = CGRectMake((int)(-1 * wd), 60, wd, ht - 60);
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         notificationView.frame = notificationFrame;
                         groupView.frame = groupFrame;
                         eventsView.frame = eventFrame;
                     }
                     completion:^(BOOL finished){ }];
}

-(void)menuButtonClick:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self];
        return;
    }
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFNotificationView *notificationView;
    MFGroupView *groupView;
    MFEventsView *eventsView;
    for(UIView *subview in self.subviews)
    {
        if([subview isMemberOfClass:[MFNotificationView class]])
            notificationView = (MFNotificationView *)subview;
        else if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
        else if([subview isMemberOfClass:[MFGroupView class]])
            groupView = (MFGroupView *)subview;
    }
    
    CGRect notificationFrame = CGRectMake((int)(-1 * wd), 60, wd, ht- 60);
    CGRect groupFrame = CGRectMake(wd, 60, wd, ht - 60);
    CGRect eventFrame = CGRectMake(0, 60, wd, ht - 60);
    if(notificationView.frame.origin.x < 0) {
        [notificationView loadNotifications];
        notificationFrame = CGRectMake(0, 60, wd, ht- 60);
        eventFrame = CGRectMake((wd * 3) / 4, 60, wd, ht - 60);
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         notificationView.frame = notificationFrame;
                         groupView.frame = groupFrame;
                         eventsView.frame = eventFrame;
                     }
                     completion:^(BOOL finished){ }];

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

    [self setup];
    [self refreshEvents];
}



//////////////////////
///// Website ////////
//////////////////////

//-(void)loadWebsite
//{
//    NSUInteger referenceId = [[Session sessionVariables][@"referenceId"] integerValue];
//    if(referenceId > 0)
//    {
//        [self joinEvent:referenceId];
//        return;
//    }
//    
//    [MFHelpers showProgressView:self];
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//    
//    for(UIView *subview in self.subviews)
//    {
//        if(![subview isKindOfClass:[UIImageView class]])
//            [subview removeFromSuperview];
//    }
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
//    [self.webView setScalesPageToFit:YES];
//    self.webView.scrollView.bounces = NO;
//    self.webView.delegate = self;
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    double lat = location == NULL ? 0 : location.latitude;
//    double lng = location == NULL ? 0 : location.longitude;
//    
//    NSString *fbAccessToken = appDelegate.fbAccessToken == NULL ? @"" : appDelegate.fbAccessToken;
//    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&fbAccessToken=%@&deviceId=%@&pushDeviceToken=%@&lat=%f&lng=%f", fbAccessToken, uuid, uuid, lat, lng];
//    NSLog(@"%@", urlAddress);
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:requestObj];
//    
//    [self addSubview:self.webView];
//    [MFHelpers hideProgressView:self];
//    
//    
////    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(0, 60, 200, 40)];
////    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
////    //loginButton.center = self.center;
////    [self addSubview:loginButton];
//    
//    
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:FacebookLogin"]) {
//        
//        [MFLoginView facebookLogin];
//        
//        return NO;
//    }
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:GetContacts"]) {
//        
//        NSString *contacts = [[MFAddressBook getContacts] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//        NSString *function = [NSString stringWithFormat:@"iOSContacts(\"%@\")", contacts];
//        
//        [self.webView stringByEvaluatingJavaScriptFromString:function];
//        
//        return NO;
//    }
//    /*
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromCreate"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
//        
//        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:nil];
//        [MFHelpers open:addressBook onView:self];
//
//        return NO;
//    }
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:InviteFromDetails"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location];
//        NSRange eventParam = [params rangeOfString:@"&currentEvent="];
//        NSString *eventUrl = [params substringFromIndex:eventParam.location + eventParam.length];
//        
//        Event *event = [[Event alloc] initFromUrl:eventUrl];
//        
//        MFAddressBook *addressBook = [[MFAddressBook alloc] initFromWebsite:params event:event];
//        [MFHelpers open:addressBook onView:self];
//        
//        return NO;
//    }
//    */
//    if ([[[request URL] absoluteString] hasPrefix:@"ios:SendSMS"]) {
//        
//        NSString *urlString = [[request URL] absoluteString];
//        NSString *params = [urlString substringFromIndex:[urlString rangeOfString:@"?"].location + 1];
//        
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        for (NSString *keyValuePair in [params componentsSeparatedByString:@"&"])
//        {
//            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
//            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
//            
//            [dict setObject:value forKey:key];
//        }
//
//        ViewController *vc = (ViewController *)self.window.rootViewController;
//        [vc sendTextMessage:[[dict objectForKey:@"phone"] componentsSeparatedByString:@","] message:[dict objectForKey:@"message"]];
//        
//        return NO;
//    }
//    
//    return YES;
//}
//
//-(void)sendLatLngToWeb
//{
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    if(location == NULL)
//        return;
//    
//    NSString *function = [NSString stringWithFormat:@"ReceiveLocation(\"%f\",\"%f\")", location.latitude, location.longitude];    
//    if(self.webView != NULL)
//        [self.webView stringByEvaluatingJavaScriptFromString:function];
//}
//
//-(void)returnAddressList:(NSString *)params
//{
//        /*
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactList options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [self urlEncodeJSON:jsonString];
//        params = [NSString stringWithFormat:@"%@&contactList=%@", params, jsonString];
//        */
//        NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/%@", params];
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlAddress]];
//        [self.webView loadRequest:requestObj];
//}
//
//-(void)goToEvent:(NSUInteger)referenceId
//{
//    if(self.webView == nil)
//    {
//        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
//        
//        for(UIView *subview in self.subviews)
//            [subview removeFromSuperview];
//        
//        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,wd,ht)];
//        [self.webView setScalesPageToFit:YES];
//        self.webView.scrollView.bounces = NO;
//        self.webView.delegate = self;
//        [self addSubview:self.webView];
//    }
//    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&goToEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
//    BOOL toMessaging = [[Session sessionVariables][@"toMessaging"] boolValue];
//    if(toMessaging)
//        urlAddress = [NSString stringWithFormat:@"%@&toMessaging=true", urlAddress];
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//
//    [self.webView loadRequest:requestObj];
//}
//
//-(void)joinEvent:(NSUInteger)referenceId
//{
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
//    
//    NSString *urlAddress = [NSString stringWithFormat:@"http://joinpowwow.azurewebsites.net/App/?OS=iOS&facebookId=%@&firstName=%@&lat=%f&lng=%f&joinEvent=%lu", appDelegate.facebookId, appDelegate.firstName, location.latitude, location.longitude, (unsigned long)referenceId];
//    NSURL *url = [[NSURL alloc] initWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:requestObj];
//}
//
//-(NSString *)urlEncodeJSON:(NSString *)json;
//{
//    return [json stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//}
//
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"%@", error);
//}
//
//-(void)webViewDidFinishLoad:(UIWebView *)webView {
//    webView.keyboardDisplayRequiresUserAction = NO;
//    if(!webView.loading)
//        [self sendLatLngToWeb];
//}





@end
