//
//  ViewController.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "MFView.h"
#import "Session.h"
#import "School.h"

@class MFView;

@interface ViewController : UIViewController <CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, strong) MFView *mainView;
@property (strong, nonatomic) CLLocationManager *locationManager;

-(void)sendTextMessage:(NSArray *)phoneNumbers message:(NSString *)message;
- (void)selectMessagePhoto;

@end

