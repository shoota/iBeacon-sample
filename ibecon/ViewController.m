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
@property (weak, nonatomic) IBOutlet UITextField *UUID;
@property (weak, nonatomic) IBOutlet UITextField *iBeaconMajor;
@property (weak, nonatomic) IBOutlet UITextField *iBeaconMinor;
@property (weak, nonatomic) IBOutlet UITextField *rangeMessage;
@property (weak, nonatomic) IBOutlet UITextField *rssiPower;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.uuidString = @"EE29A799-1E19-4315-993B-C30ACF58103F";

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
        
        // FIXME
        self.UUID.text = self.uuidString;
        
    }
}

/* ---------------------------------------------------------------
         locationManager delegate methods
 ---------------------------------------------------------------*/
// regionに入った時
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //region測定の開始
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// regionから出たとき
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // Beaconの距離測定を終了する
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    //region out の表示
    self.messageLabel.text = @"Disconnected.";
}

// モニタリングが正常開始されているとき
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    // 現在状況を取得。didDetermineStateがdelegateとして呼ばれる
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

// 監視状態が決定したとき
- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        // Regionの中にいればRangingを始める
        case CLRegionStateInside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
            
        case CLRegionStateOutside:
            self.messageLabel.text = @"No signals.";
        case CLRegionStateUnknown:
            self.messageLabel.text = @"Searching iBeacon.";
        default:
            break;
    }
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
                self.messageLabel.text = @"No Signal";
                break;
        }
        
        // ローカル通知
//        NSString *message = [NSString stringWithFormat:@"UUID:%@ \n major:%@ \n minor:%@ \n",
//                             self.uuidString, nearestBeacon.major, nearestBeacon.minor];
//        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];

        
        NSString *rssi  = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.rssi];
        NSString *major = [NSString stringWithFormat:@"%@", nearestBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
        
        self.messageLabel.text = @"Connecting";
        self.iBeaconMajor.text = major;
        self.iBeaconMinor.text = minor;
        
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

- (IBAction)refreshConnection:(id)sender {
    self.messageLabel.text = @"Restarting Reciever.";
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}
@end
