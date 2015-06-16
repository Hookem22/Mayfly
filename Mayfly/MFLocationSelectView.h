//
//  MFLocationSelectView.h
//  Mayfly
//
//  Created by Will Parks on 5/27/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MFCreateView.h"

@interface MFLocationSelectView : UIView <MKMapViewDelegate>

-(id)init:(UIView *)returnView;

@end
