//
//  ViewController.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "ViewController.h"
#import "MFView.h"

@interface ViewController ()

@property(nonatomic, strong) MFView *mainView;

@end

@implementation ViewController

- (void)loadView {
    
    self.mainView = [[MFView alloc] init];
    self.view = self.mainView;
    
    //debugging only
    //if (TARGET_IPHONE_SIMULATOR)
    //{
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(30.2500, -97.7500);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];
        [[Session sessionVariables] setObject:location forKey:@"location"];
        
        [self.mainView setup];
    //}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
