//
//  ViewController.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MFView.h"
#import "Session.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property(nonatomic, strong) MFView *mainView;


@end

