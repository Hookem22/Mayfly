//
//  ViewController.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController


- (void)loadView {
    
    self.mainView = [[MFView alloc] init];
    self.view = self.mainView;
    
    //debugging only
    if (TARGET_IPHONE_SIMULATOR)
    {
        //CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(30.2500, -97.7500);
        //CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
        Location *location = [[Location alloc] init];
        location.latitude = 30.2500;
        location.longitude = -97.7500;
        [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
        
        [self.mainView setup];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        //_locationManager.pausesLocationUpdatesAutomatically = NO;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No GPS"
                                                        message:@"Please Turn On Location to Find Events Near You"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    /*
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"No GPS"
                               message:@"Please Turn On Location to Find Events Near You"
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
    [errorAlert show];
    */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* cllocation = [locations lastObject];
    
    [_locationManager stopUpdatingLocation];
    
    Location *ckLocation = (Location *)[Session sessionVariables][@"currentLocation"];
    if(ckLocation != nil)
        return;
    
    Location *location = [[Location alloc] init];
    location.latitude = cllocation.coordinate.latitude;
    location.longitude = cllocation.coordinate.longitude;

    [[Session sessionVariables] setObject:location forKey:@"currentLocation"];
    
    /*for(id subview in self.mainView.subviews) { //Bug for loading cards twice
        if([subview isMemberOfClass:[DWDraggableView class]] || [subview isMemberOfClass:[DWLeftSideBar class]] )
            return;
    }*/
    
    [self.mainView setup];
    
}

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
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mainView setup];
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
