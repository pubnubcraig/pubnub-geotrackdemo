//
//  ViewController.m
//  LocationFinderDemo
//
//  Created by pubnubcvconover on 9/26/15.
//  Copyright © 2015 pubnubcvconover. All rights reserved.
//

#import "ViewController.h"
#import<CoreLocation/CoreLocation.h>


@interface ViewController ()
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@end

@implementation ViewController

@synthesize locationManager;
@synthesize pubnub;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.stopButton setEnabled:FALSE];
    
    PNConfiguration *configuration = [PNConfiguration
                                      configurationWithPublishKey:@"pub-c-7a1896a7-c8d7-4a44-9815-e033e5487246"
                                      subscribeKey:@"sub-c-fae8895e-6344-11e5-9f3a-0693d8625082"];
    
    self.pubnub = [PubNub clientWithConfiguration:configuration];
    [self.pubnub addListener:self];
    
    //    we are not subscribing, only publishing
    //    [self.pubnub subscribeToChannels:@[@"my_channel"] withPresence:YES];
    
    geocoder = [[CLGeocoder alloc] init];
    if (locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDelegate:self];
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }

        NSLog(@"locationManager is all setup");
    }
    
    NSLog(@"exiting viewDidLoad");
}


- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];

    NSLog(@"locationManager didUpdateLocations");
    NSLog(@"%@", [locations lastObject]);
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            NSString *latitude, *longitude, *state, *country;
            
            latitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
            longitude = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
            state = placemark.administrativeArea;
            country = placemark.country;

            NSLog(@"********* Updating Location *********");
            NSLog(@"latitude: %@", latitude);
            NSLog(@"longitude: %@", longitude);
//            NSLog(@"state: %@", state);
//            NSLog(@"country: %@", country);
            NSLog(@" ");
            
            NSArray *data = @[@{@"latlng" : @[latitude, longitude]}];
            
            [self.lngValue setText:longitude];
            [self.latValue setText:latitude];
            
            [self sendLocation:data];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    // Turn off the location manager to save power.
//    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Cannot find the location.");
}


- (void)pubnub:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    // Handle new message stored in message.data.message
    if (message.data.actualChannel) {
        
        // Message has been received on channel group stored in
        // message.data.subscribedChannel
    }
    else {
        
        // Message has been received on channel stored in
        // message.data.subscribedChannel
    }
    
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
          message.data.subscribedChannel, message.data.timetoken);
}



- (void)pubnub:(PubNub *)pubnub didReceiveStatus:(PNSubscribeStatus *)status {
    
    if (status.category == PNUnexpectedDisconnectCategory) {
        // This event happens when radio / connectivity is lost
    }
    
    else if (status.category == PNConnectedCategory) {
        
        // Connect event. You can do stuff like publish, and know you'll get it.
        // Or just use the connected event to confirm you are subscribed for
        // UI / internal notifications, etc
        
//        [self.pubnub publish:@"Hello from the PubNub Objective-C SDK" toChannel:@"my_channel"
//              withCompletion:^(PNPublishStatus *status) {
//                  
//                  // Check whether request successfully completed or not.
//                  if (!status.isError) {
//                      
//                      // Message successfully published to specified channel.
//                  }
//                  // Request processing failed.
//                  else {
//                      
//                      // Handle message publish error. Check 'category' property to find out possible issue
//                      // because of which request did fail.
//                      //
//                      // Request can be resent using: [status retry];
//                  }
//              }];
    }
    else if (status.category == PNReconnectedCategory) {
        
        // Happens as part of our regular operation. This event happens when
        // radio / connectivity is lost, then regained.
    }
    else if (status.category == PNDecryptionErrorCategory) {
        
        // Handle messsage decryption error. Probably client configured to
        // encrypt messages and on live data feed it received plain text.
    }
    
}


- (void)sendLocation:(NSArray *)payload {
    
    [self.pubnub publish:payload toChannel:@"pnrace" withCompletion:^(PNPublishStatus *status) {
              
              // Check whether request successfully completed or not.
              if (!status.isError) {
                  
                  // Message successfully published to specified channel.
              }
              // Request processing failed.
              else {
                  
                  // Handle message publish error. Check 'category' property to find out possible issue
                  // because of which request did fail.
                  //
                  // Request can be resent using: [status retry];
              }
          }];
}


- (IBAction)startButton:(id)sender {
    [self.locationManager startUpdatingLocation];
    [self.startButton setEnabled:FALSE];
    [self.stopButton setEnabled:TRUE];
    [self.nameText setEnabled:FALSE];
}

- (IBAction)stopButton:(id)sender {
    [self.locationManager stopUpdatingLocation];
    [self.stopButton setEnabled:FALSE];
    [self.startButton setEnabled:TRUE];
    [self.nameText setEnabled:TRUE];
}

@end
