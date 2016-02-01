//
//  MFGroupDetailView.h
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFLoginView.h"

@interface MFGroupDetailView : UIView

-(id)init:(Group *)group;
-(void)setup:(Group *)group;

@end
