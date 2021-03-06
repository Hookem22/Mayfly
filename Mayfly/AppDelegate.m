	//
//  AppDelegate.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Branch-SDK/Branch.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL appInBackground;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    Branch *branch = [Branch getInstance];
//    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
//        // params are the deep linked params associated with the link that the user clicked before showing up.
//        NSLog(@"deep link data: %@", [params description]);
//        if(!error && params != nil && [params objectForKey:@"ReferenceId"] != nil) {
//            [[Session sessionVariables] setObject:[params objectForKey:@"ReferenceId"] forKey:@"referenceId"];
//             NSLog(@"%@", [params objectForKey:@"ReferenceId"]);
//            
//            self.hasNotifications = YES;
//            ViewController *vc = (ViewController *)self.window.rootViewController;
//            if(vc != nil) {
//                MFView *mfView = (MFView *)vc.mainView;
//                if(mfView != nil)
//                {
//                    [mfView goToEvent:[[params objectForKey:@"ReferenceId"] intValue]];
//                }
//            }
//        }
//    }];

    /*
    if([launchOptions count] > 0) //ReferenceId on first launch
    {
        NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        if(url != nil && [url query] != nil)
            [[Session sessionVariables] setObject:[url query] forKey:@"referenceId"];
    }
    */
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |
//                                                    UIUserNotificationTypeSound);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                             categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//
   
    //Send to event on app launch
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        
        if (apsInfo) {
            
            NSString *message = [apsInfo valueForKey:@"message"];
            NSString *header = [message substringToIndex:[message rangeOfString:@"|"].location];
            if([header isEqualToString:@"Post"]) {
                self.postId = [message substringFromIndex:[message rangeOfString:@"|"].location + 1];
            }
            else {
                self.eventId = [message substringFromIndex:[message rangeOfString:@"|"].location + 1];
            }
        }
    }

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                               didFinishLaunchingWithOptions:launchOptions];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    self.appInBackground = NO;
    self.hasNotifications = application.applicationIconBadgeNumber > 0;
    //self.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    application.applicationIconBadgeNumber = 0;
    
    [FBSDKAppEvents activateApp];
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"id,name,first_name,email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 NSLog(@"access token:%@", [FBSDKAccessToken currentAccessToken].tokenString);
                 //self.facebookId = @"10106610968977054";//[result objectForKey:@"id"];
                 //self.name = @"Bob Sherriff"; //[result objectForKey:@"name"];
                 //self.firstName = @"Bob"; // [result objectForKey:@"first_name"];
                 
                 self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                                 
                 User *user = [[User alloc] init];
                 user.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                 user.pushDeviceToken = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                 user.facebookId = [result objectForKey:@"id"];
                 user.name = [result objectForKey:@"name"];
                 user.firstName = [result objectForKey:@"first_name"];
                 user.email = [result objectForKey:@"email"];
                 
//                 self.facebookId = [result objectForKey:@"id"];
//                 self.name = [result objectForKey:@"name"];
//                 self.firstName = [result objectForKey:@"first_name"];
//                 self.email = [result objectForKey:@"email"];
                 
                 [self LoginUser:user];
             }
             else {
                 [self LoadEvents];
             }
             
             //Register for push notifications after login
             UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                             UIUserNotificationTypeBadge |
                                                             UIUserNotificationTypeSound);
             UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                      categories:nil];
             [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
             [[UIApplication sharedApplication] registerForRemoteNotifications];
         }];
    }
    else {
        [self LoadEvents];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[Branch getInstance] handleDeepLink:url]) {
        return YES;
    }
    /*
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    if([url query] != nil)
    {
        [[Session sessionVariables] setObject:[url query] forKey:@"referenceId"];
        
        ViewController *vc = (ViewController *)self.window.rootViewController;
        MFView *mfView = (MFView *)vc.mainView;
        [mfView refreshEvents];
    }
    */
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:@"Endpoint=sb://mayflyapphub-ns.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=KdLzdARZgqnLMU6/ft+4Jln7YOWTPtUGAZCSrP5GcqI="
                                                             notificationHubPath:@"mayflyapphub"];
    
    //NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    //self.deviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];
    //self.deviceToken = [self.deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSSet *set = [[NSSet alloc] initWithObjects:uuid, nil];
    //NSLog(@"%@", set);
    [hub registerNativeWithDeviceToken:deviceToken tags:set completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
        else {
            //NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
            //self.deviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];
            //NSLog(@"%@", self.deviceToken);
            
            //Will accept this before logging in
            //[self LoginUser];
        }
    }];
}

-(void)LoginUser:(User *)user {

    if([user isKindOfClass:[NSNull class]] || user.userId.length <= 0)
    {
        [User login:user completion:^(User *newUser) {
            //NSLog(@"%@", newUser.goingEventIds);
            //NSLog(@"%@", newUser.invitedEventIds);
            
            [self LoadEvents];
            //self.appUser = user;
            //ViewController *vc = (ViewController *)self.window.rootViewController;
            //MFView *mfView = (MFView *)vc.mainView;
            //[mfView loadWebsite];
        }];
    }
}

-(void)LoadEvents
{
    ViewController *vc = (ViewController *)self.window.rootViewController;
    MFView *mfView = (MFView *)vc.mainView;
    [mfView refresh];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
//    NSLog(@"%@", userInfo);
//    
    
    NSDictionary *message = [userInfo objectForKey:@"aps"];
    if(message)
    {
        NSString *event = [message valueForKey:@"message"];
        if(event && [event rangeOfString:@"|"].location != NSNotFound)
        {
            NSString *header = [event substringToIndex:[event rangeOfString:@"|"].location];
            if([header isEqualToString:@"Post"]) {
                self.postId = [event substringFromIndex:[event rangeOfString:@"|"].location + 1];
                if(self.appInBackground == YES) {
                    [self openPost];
                }
                else {
                    [self MessageBox:header message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
                }
            }
            else
            {
                self.eventId = [event substringFromIndex:[event rangeOfString:@"|"].location + 1];
                
                if(self.appInBackground == YES) {
                    [self openEvent];
                }
                else {
                    [self MessageBox:header message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
                }
            }
        }
    }
}

-(void)MessageBox:(NSString *)title message:(NSString *)messageText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:messageText
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Go", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
            if(![self.eventId isMemberOfClass:[NSNull class]] && self.eventId != nil && self.eventId.length > 0)
                [self openEvent];
            else
                [self openPost];
            break;
    }
}

-(void)openEvent
{
    ViewController *vc = (ViewController *)self.window.rootViewController;
    MFView *mfView = (MFView *)vc.mainView;
    [mfView goToEvent:self.eventId];
    self.eventId = @"";
    
//    ViewController *vc = (ViewController *)self.window.rootViewController;
//    MFView *mfView = (MFView *)vc.mainView;
//    //[mfView openEvent:self.eventId toMessaging:toMessaging];
//    
//    [[Session sessionVariables] setValue:[NSNumber numberWithBool:toMessaging] forKey:@"toMessaging"];
//    [Event get:self.eventId completion:^(Event *event) {
//        [mfView goToEvent:event.referenceId];
//    }];
    
}

-(void)openPost
{
    ViewController *vc = (ViewController *)self.window.rootViewController;
    MFView *mfView = (MFView *)vc.mainView;
    [mfView goToPost:self.postId];
    self.postId = @"";
}

// We are registered, so now store the device token (as a string) on the AppDelegate instance
// taking care to remove the angle brackets first.
/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken {
    NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    self.deviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];
    //self.deviceToken = [self.deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", self.deviceToken);
    
    [self LoginUser];
}
*/
// Handle any failure to register. In this case we set the deviceToken to an empty
// string to prevent the insert from failing.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:
(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
    //self.deviceToken = @"";
}


/*- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.appInBackground = YES;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/*- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}*/

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
