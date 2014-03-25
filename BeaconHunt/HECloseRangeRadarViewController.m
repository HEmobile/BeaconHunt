//
//  HECloseRangeRadarViewController.m
//  BeaconHunt
//
//  Created by Roberto Silva on 17/01/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "HECloseRangeRadarViewController.h"

#import <ESTBeaconManager.h>

#define DOT_MIN_POS 120
#define DOT_MAX_POS screenHeight - 70;

@interface HECloseRangeRadarViewController() <ESTBeaconManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) UIImageView*      positionDot;
@property (nonatomic, strong) ESTBeacon*        selectedBeacon;

@property (nonatomic) float dotMinPos;
@property (nonatomic) float dotRange;

@end

@implementation HECloseRangeRadarViewController

#pragma mark - View Setup

- (void)setupBackgroundImage
{
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (screenHeight > 480) {
        self.backgroundImageView.image = [UIImage imageNamed:@"backgroundBig"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"backgroundSmall"];
    }
}

- (void)setupDotImage
{
    self.positionDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot setCenter:self.view.center];
    [self.positionDot setAlpha:1.0f];
    
    [self.view addSubview:self.positionDot];
    
    self.dotMinPos = 150;
    self.dotRange = self.view.bounds.size.height  - 220;
}

- (void)setupView
{
    [self setupBackgroundImage];
    [self setupDotImage];
}

#pragma mark - Manager setup

- (void)setupManager
{
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupManager];
    [self setupView];
}

#pragma mark - ESTBeaconManagerDelegate Implementation

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        for (ESTBeacon* cBeacon in beacons)
        {
            // update beacon it same as selected initially
            //NSLog(@"selected Beacon minor:%@",self.beacon.minorId);
            //NSLog(@"current Beacon minor:%@",cBeacon.minor);
            if([self.beacon.majorId unsignedShortValue] == [cBeacon.major unsignedShortValue] &&
               [self.beacon.minorId unsignedShortValue] == [cBeacon.minor unsignedShortValue])
            {
                //NSLog(@"found beacon");
                self.selectedBeacon = cBeacon;
            }
        }
        
        if (self.selectedBeacon) {
            // based on observation rssi is not getting bigger then -30
            // so it changes from -30 to -100 so we normalize
            float distFactor = ((float)self.selectedBeacon.rssi + 30) / -70;
            
            // calculate and set new y position
            float newYPos = self.dotMinPos + distFactor * self.dotRange;
            self.positionDot.center = CGPointMake(self.view.bounds.size.width / 2, newYPos);
        }
    }
}

- (IBAction)foundBeacon:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beacon Encontrado"
                                                    message:@"Digite a senha descoberta para registrar esse beacon"
                                                   delegate: self
                                          cancelButtonTitle:@"Cancelar"
                                          otherButtonTitles:@"Ok", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%li",(long)buttonIndex);
    // 0 = Later, 1 = Now, 2 = Never;
    if (buttonIndex == 1) {
        NSLog(@"PASSWORD:%@",[alertView textFieldAtIndex:0].text);
        
    }
}

//- (void)registerFoundedBeacon


@end
