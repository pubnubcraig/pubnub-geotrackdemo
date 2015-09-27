//
//  ViewController.h
//  LocationFinderDemo
//
//  Created by pubnubcvconover on 9/26/15.
//  Copyright © 2015 pubnubcvconover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <PubNub/PubNub.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, PNObjectEventListener> {
    CLLocationManager *locationManager;
    PubNub *pubnub;

}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) PubNub *pubnub;

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *latValue;
@property (weak, nonatomic) IBOutlet UILabel *lngValue;
@property (weak, nonatomic) UIButton *startButton;
@property (weak, nonatomic) UIButton *stopButton;

- (IBAction)startButton:(id)sender;
- (IBAction)stopButton:(id)sender;

@end

