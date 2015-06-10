//
//  MFMapView.m
//  Mayfly
//
//  Created by Will Parks on 5/26/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFLocationSelectView.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MFLocationSelectView ()

@property (nonatomic, strong) UITextField *searchText;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) UIView *returnView;

@end

@implementation MFLocationSelectView

-(id)initWithFrame:(CGRect)frame returnView:(UIView *)returnView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.returnView = returnView;
        self.backgroundColor = [UIColor whiteColor];
        
        [self setup];
    }
    return self;
}

-(void)setup
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"Add Location";
    [self addSubview:headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 30, 80, 40);
    [self addSubview:cancelButton];
    
    UITextField *searchText = [[UITextField alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 30)];
    [searchText addTarget:self action:@selector(searchPlaces:) forControlEvents:UIControlEventEditingChanged];
    searchText.borderStyle = UITextBorderStyleRoundedRect;
    searchText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    searchText.font = [UIFont systemFontOfSize:15];
    searchText.placeholder = @"Search";
    self.searchText = searchText;
    [self addSubview:self.searchText];
    
}

-(void)searchPlaces:(id)sender
{
    [self queryFacebookPlaces];
}

-(void)queryFacebookPlaces
{
    CLLocationCoordinate2D currentCentre = CLLocationCoordinate2DMake(30.2500, -97.7500);
    int radius = 5000;
    NSString *placeName = [self.searchText.text stringByReplacingOccurrencesOfString:@" " withString:@"%22"];
    if([placeName length] < 3)
    {
        if([placeName length] == 0)
        {
            for(id subview in self.subviews)
            {
                if([subview isMemberOfClass:[UIScrollView class]])
                    [subview removeFromSuperview];
            }
        }
        return;
    }
    
    NSString *appId = @"397533583786525";
    NSString *appSecret = @"00304650c1c7fd526c7fb265b606fe57";
    NSString *accessToken = [NSString stringWithFormat:@"%@|%@", appId, appSecret];
    
    //NSString *accessToken = @"CAAFpjgAMQh0BAN9opav6Iifjftb4Xi5xMq6NUlxvxpqJruZAzAKba5JvkUZC5a3aycS3pS9fePiyfteSZCtVF8vP2KLz0cWo1aHjAmYBxYDRMDCmbXdl6JgePfp6U1LoWm8PHcN544p03EWjRZAlE5qx2uulUfWO6e6cTMJ11od5huEJFw8G8zt5ZAqxFRAdEpYaWiZCEg7b7KR1jOUCfh";
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/v2.3/search?q=%@&type=place&center=%f,%f&distance=%d&access_token=%@", placeName, currentCentre.latitude, currentCentre.longitude, radius, accessToken];
    
    NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *requestURL=[NSURL URLWithString:webStringURL];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: requestURL];
        [self performSelectorOnMainThread:@selector(fetchedFacebookData:) withObject:data waitUntilDone:YES];
    });
    
    /*
     FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
     initWithGraphPath:@"/{place-tag-id}"
     parameters:params
     HTTPMethod:@"GET"];
     [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
     id result,
     NSError *error) {
     NSLog(@"%@", error);
     NSLog(@"%@", result);
     }];
     */
}

-(void)fetchedFacebookData:(NSData *)responseData {
    if(responseData == nil)
        return;
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* places = [json objectForKey:@"data"];
    
    //Write out the data to the console.
    //NSLog(@"FB Data: %@", places);
    [self populateFacebookData:places];
}

-(void)populateFacebookData:(NSArray *)places
{
    self.places = places;
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(id subview in self.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, wd, ht-110)];
    [self addSubview:scrollView];
    
    int skip = 0;
    for(int i = 0; i < [places count]; i++)
    {
        NSDictionary *place = [places objectAtIndex:i];
        NSString *name = [place valueForKey:@"name"];
        NSObject *location = [place valueForKey:@"location"];
        NSString *address = [location valueForKey:@"street"];
        double latitude = [[location valueForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"latitude"] doubleValue];
        double longitude = [[location valueForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"longitude"] doubleValue];
        if(latitude == 0 || longitude == 0)
        {
            skip++;
            continue;
        }
        else if(i - skip > 0)
        {
            NSDictionary *prevPlace = [places objectAtIndex:i - skip - 1];
            //NSString *prevName = [prevPlace valueForKey:@"name"];
            location = [prevPlace valueForKey:@"location"];
            double prevLatitude = [[location valueForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"latitude"] doubleValue];
            double prevLongitude = [[location valueForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[location valueForKey:@"longitude"] doubleValue];
            
            if((fabs(latitude - prevLatitude) < .02 && fabsf(longitude - prevLongitude) < .02) /*|| [name isEqualToString:prevName]*/)
            {
                skip++;
                continue;
            }
        }
        
        UIButton *placeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [placeButton setTitle:name forState:UIControlStateNormal];
        [placeButton addTarget:self action:@selector(placeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        placeButton.frame = CGRectMake(30, ((i - skip) * 60), wd - 60, 70);
        placeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [placeButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        placeButton.tag = i;
        [scrollView addSubview:placeButton];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd - 60, 30)];
        addressLabel.text = address;
        [addressLabel setFont:[UIFont systemFontOfSize:12]];
        [placeButton addSubview:addressLabel];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, placeButton.frame.size.height - 1.0f, placeButton.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        [placeButton addSubview:bottomBorder];
        
        scrollView.contentSize = CGSizeMake(wd, (((i - skip) + 2) * 100));
    }
    
    if([places count] == 0)
    {
        UIButton *nameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [nameButton setTitle:[NSString stringWithFormat:@"Just use \"%@\"", self.searchText.text] forState:UIControlStateNormal];
        [nameButton addTarget:self action:@selector(getLatLngFromAddress:) forControlEvents:UIControlEventTouchUpInside];
        nameButton.frame = CGRectMake(30, 0, wd - 60, 70);
        nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //[nameButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        //nameButton.tag = -1;
        [scrollView addSubview:nameButton];
    }
}

-(void)placeButtonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSDictionary *place = [self.places objectAtIndex:button.tag];
    NSLog(@"%@", place);
    NSDictionary *loc = [place objectForKey:@"location"];
    Location *location = [[Location alloc] init:loc];
    location.name = [place objectForKey:@"name"];
    location.address = [NSString stringWithFormat:@"%@, %@, %@", [loc objectForKey:@"street"], [loc objectForKey:@"city"], [loc objectForKey:@"state"]];
    
    [self returnPlace:location];
}

-(void)returnPlace:(Location *)location
{
    MFLocationView *locationView = (MFLocationView *)self.returnView;
    [locationView locationReturn:location];
    
    [self close];
}

-(void)getLatLngFromAddress:(id)sender
{
    NSString *address = [NSString stringWithFormat:@"%@, %@, %@", self.searchText.text, @"Austin", @"TX"];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=false", address];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
        [self performSelectorOnMainThread:@selector(fetchedGeoData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedGeoData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    [location setObject:self.searchText.text forKey:@"name"];
    [location setObject:self.searchText.text forKey:@"address"];
    
    NSDictionary *loc = [[results valueForKey:@"geometry"] valueForKey:@"location"];
    NSArray *latitude = [loc valueForKey:@"lat"];
    NSArray *longitude = [loc valueForKey:@"lng"];
    NSNumber *lat = [latitude objectAtIndex:0];
    NSNumber *lng = [longitude objectAtIndex:0];
    [location setObject:lat forKey:@"latitude"];
    [location setObject:lng forKey:@"longitude"];
    
    [self returnPlace:[[Location alloc] init:location]];
}

-(void) queryGooglePlaces: (NSString *) googleType {
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    //NSString *kGOOGLE_API_KEY = @"AIzaSyA1Viw-vy8_HSZmS02R9MBMoyNsYi5y2ME";
    CLLocationCoordinate2D currentCentre = CLLocationCoordinate2DMake(30.2500, -97.7500);
    int radius = 1000;
    NSString *placeName = [self.searchText.text stringByReplacingOccurrencesOfString:@" " withString:@"%22"];
    
    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currentDist], googleType, kGOOGLE_API_KEY];
    
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d%@&name=%@&sensor=false&key=AIzaSyA1Viw-vy8_HSZmS02R9MBMoyNsYi5y2ME", currentCentre.latitude, currentCentre.longitude, radius, googleType, placeName];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedGoogleData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedGoogleData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
}

-(void)cancelButtonClick:(id)sender
{
    [self close];
}

-(void)close
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, ht, wd, ht - 60);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

@end
