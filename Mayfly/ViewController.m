//
//  ViewController.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)loadView {
    self.mainView = [[MFView alloc] init];
    self.view = self.mainView;
    
    //Default to St. Edward's
//    Location *location = [[Location alloc] init];
//    location.latitude = 30.2290; //St. Edward's
//    location.longitude = -97.7560;
//    [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
//    
//    NSDictionary *schoolDict = @{@"id": @"E1668987-C219-484C-B5BB-1ACACDCADE17", @"name": @"St. Edward's", @"latitude": @"30.231", @"longitude": @"-97.758" };
//    [[Session sessionVariables] setObject:[[School alloc] init: schoolDict] forKey:@"currentSchool"];

    Location *location = [[Location alloc] init];
    location.latitude = 0.1; //Test
    location.longitude = 0.1;
    [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
    
    NSDictionary *schoolDict = @{@"id": @"32F991FE-15A0-4436-8CD2-C46413ABB1CA", @"name": @"Test School", @"latitude": @"0", @"longitude": @"0" };
    [[Session sessionVariables] setObject:[[School alloc] init: schoolDict] forKey:@"currentSchool"];
    
    [self.mainView setup];
    
    //[self.mainView loadWebsite];
    
//    //debugging only
//    if (TARGET_IPHONE_SIMULATOR)
//    {
//        //CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(30.2500, -97.7500);
//        //CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
//        Location *location = [[Location alloc] init];
//        location.latitude = 30.2290; //St. Edward's
//        location.longitude = -97.7560;
//        [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
//        
//        //[self.mainView setup];
//        //[self.mainView loadWebsite];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    if ([CLLocationManager locationServicesEnabled] &&
//        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
//        _locationManager = [[CLLocationManager alloc] init];
//        
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        _locationManager.delegate = self;
//        //_locationManager.pausesLocationUpdatesAutomatically = NO;
//        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [self.locationManager requestWhenInUseAuthorization];
//        }
//        [_locationManager startUpdatingLocation];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No GPS"
//                                                        message:@"Please Turn On Location to Find Events Near You"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    if ([error domain] == kCLErrorDomain) {
//        
//        // We handle CoreLocation-related errors here
//        switch ([error code]) {
//                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
//                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
//            case kCLErrorDenied:
//            {
//                UIAlertView *errorAlert = [[UIAlertView alloc]
//                                           initWithTitle:@"No GPS"
//                                           message:@"Please Turn On Location to Find Events Near You"
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                [errorAlert show];
//                break;
//            }
//            case kCLErrorLocationUnknown:
//            {
//                UIAlertView *errorAlert = [[UIAlertView alloc]
//                                           initWithTitle:@"No GPS"
//                                           message:@"Unable to find your current location."
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                [errorAlert show];
//                break;
//            }
//            default:
//                //...
//                break;
//        }
//    } else {
//        // We handle all non-CoreLocation errors here
//    }
//    
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    // If it's a relatively recent event, turn off updates to save power.
//    CLLocation* cllocation = [locations lastObject];
//    
//    [_locationManager stopUpdatingLocation];
//    
//    Location *ckLocation = (Location *)[Session sessionVariables][@"currentLocation"];
//    if(ckLocation != nil)
//        return;
//    
//    Location *location = [[Location alloc] init];
//    location.latitude = cllocation.coordinate.latitude;
//    location.longitude = cllocation.coordinate.longitude;
//
//    [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
////    [School get:location.latitude longitdue:location.longitude completion:^(School *school) {
////        if(school != nil)
////        {
////            [[Session sessionVariables] setObject:school forKey:@"currentSchool"];
////            [self.mainView setup];
////        }
////    }];
//
//    [self.mainView sendLatLngToWeb];
//    
//}

-(void)sendTextMessage:(NSArray *)phoneNumbers message:(NSString *)message
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:phoneNumbers];
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    Event *currentEvent = (Event *)[Session sessionVariables][@"currentEvent"];
    NSArray *invites = (NSArray *)[Session sessionVariables][@"currentInvites"];
    //[[Session sessionVariables] removeObjectForKey:@"eventToSend"];
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            for(NSString *name in invites) {
                [currentEvent addInvite:nil name:name completion:^(EventGoing *eventGoing) { }];
            }
            break;
        }
            
        default:
            break;
    }
    
    [[Session sessionVariables] removeObjectForKey:@"currentEvent"];
    [[Session sessionVariables] removeObjectForKey:@"currentInvites"];
    
    for(UIView *subview in self.mainView.subviews) {
        //if(![subview isMemberOfClass:[UIWebView class]])
            [subview removeFromSuperview];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mainView setup];
    [self.mainView refreshEvents];
    //[self.mainView loadWebsite];
}

- (void)selectMessagePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;
    
    for(UIView *subview in self.mainView.subviews) {
        if([subview isMemberOfClass:[MFPostMessageView class]]){
            MFPostMessageView *view = (MFPostMessageView *)subview;
            [view newImage:chosenImage];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
