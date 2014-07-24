//
//  ViewController.m
//  ibecon
//
//  Created by 熊野修太 on 2014/07/24.
//  Copyright (c) 2014年 anaguma.org. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString          *uuidString;
@property (nonatomic) NSUUID            *proximityUUID;
@property (nonatomic) CLBeaconRegion    *beaconRegion;

// UI parts
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *rangeMessage;
@property (weak, nonatomic) IBOutlet UITextField *rssiPower;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.uuidString = @"EE29A799-1E19-4315-993B-C30ACF58103F";

    self.messageLabel.text = @"Searching iBeacon...";
	if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        
        //locationManagerを生成してviewcontrollerにdelegate
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        //UUID生成
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:self.uuidString];
        
        //Beacon領域生成
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                            identifier:@"org.anaguma.beacon"];
        
        // start
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
        
    }
}

// regionに入った時
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // ローカル通知
    //[self sendLocalNotificationForMessage:@"Enter Region"];
    
    //region測定の開始
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// regionから出たとき
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // ローカル通知
    //[self sendLocalNotificationForMessage:@"Exit Region"];
    
    // Beaconの距離測定を終了する
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    
    //region out の表示
    self.messageLabel.text = @"Out Region.";
}


// locationManaerのイベントハンドリング
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        NSString *rangeMessage;
        UIColor  *rangeColor;
        
        // Beacon の距離でメッセージを変える
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"非常に近い";
                rangeColor   = [UIColor redColor];
                break;
            case CLProximityNear:
                rangeMessage = @"近い";
                rangeColor   = [UIColor orangeColor];
                break;
            case CLProximityFar:
                rangeMessage = @"遠い";
                rangeColor   = [UIColor greenColor];
                break;
            default:
                rangeMessage = @"不明";
                break;
        }
        
        // ローカル通知
        NSString *message = [NSString stringWithFormat:@"UUID:%@ \n major:%@ \n minor:%@ \n",
                             self.uuidString, nearestBeacon.major, nearestBeacon.minor];
        
        NSString *rssi = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.rssi];
        //[self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
        
        self.messageLabel.text = message;
        self.rangeMessage.text = rangeMessage;
        self.rangeMessage.backgroundColor = rangeColor;
        self.rssiPower.text = rssi;
        
    }
}


- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
