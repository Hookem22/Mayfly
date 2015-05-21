//
//  MFDetailView.h
//  Mayfly
//
//  Created by Will Parks on 5/21/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface MFDetailView : UIScrollView

-(void)open:(Event*)event;

@end
