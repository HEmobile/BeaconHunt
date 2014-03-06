//
//  HELongRangeRadarViewController.m
//  BeaconHunt
//
//  Created by Roberto Silva on 17/01/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "HELongRangeRadarViewController.h"
#import <ESTBeaconManager.h>
#import <Parse/Parse.h>
#import "Beacon.h"
#import "HECloseRangeRadarViewController.h"

NSUInteger const HEMaxBeaconsOnScreen = 3;
NSString *const HETrackBeaconSegueID = @"Track Beacon Segue";

@interface HELongRangeRadarViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) NSArray *visibleBeacons;
@property (nonatomic, strong) NSArray *visibleEstBeacons;
@property (weak, nonatomic) IBOutlet UIView *beaconContainer;
@property (weak, nonatomic) IBOutlet UIImageView *radarImageView;
@end

@implementation HELongRangeRadarViewController {
    CGFloat _radarYOrigin;
    BOOL _showedBeaconsInfo;
}

#pragma mark - LIFE CYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _radarYOrigin = self.radarImageView.frame.origin.y;
    NSLog(@"event.beacons:%u",[self.event.beacons count]);
    if (!self.visibleBeacons) {
        self.visibleBeacons = [[NSMutableArray alloc] initWithCapacity:3];
        [self setupBeacons];
    }
}

#pragma mark SETUP ESTIMOTE/BEACONS

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

- (void)setupBeacons
{
    // ONLY 3 BEACONS ARE ALLOWED ON SCREEN FOR THE MOMENT
    // IF YOU CHANGE IT, YOU MAY NEED TO CHANGE THE BEACON POSITIONS METHODS
    NSArray *beaconImages = @[@"beacon-green",@"beacon-blue",@"beacon-gray"];
    //self.visibleBeacons =
    
    NSMutableArray *beaconViewsArr = [[NSMutableArray alloc] initWithCapacity:[beaconImages count]];
    int i = 0;
    for (NSString *beaconImgName in beaconImages) {
        //UIImageView *beaconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:beaconImgName]];
        UIImage *buttonImage = [UIImage imageNamed:beaconImgName];
        UIButton *beaconView = [UIButton buttonWithType:UIButtonTypeCustom];
        beaconView.tag = i;
        beaconView.titleLabel.text = @"";
        [beaconView setImage:[UIImage imageNamed:beaconImgName] forState:UIControlStateNormal];
        beaconView.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        //[cell.likeButton addTarget:self action:@selector(likeItToogle:) forControlEvents:UIControlEventTouchUpInside];
        [beaconView addTarget:self action:@selector(trackBeacon:) forControlEvents:UIControlEventTouchUpInside];
        beaconView.hidden = YES;
        [beaconViewsArr addObject:beaconView];
        [self.beaconContainer addSubview:beaconView];
        beaconView.center = [self centerForNearBeacon:i];
        i++;
    }
    self.visibleBeacons = [beaconViewsArr copy];
}

#pragma mark - BEACON POSITIONS

- (CGPoint)centerForImmediateBeacon:(int)order
{
    int rowOrder;
    if (order%2 == 1) {
        rowOrder = (order-1)/2;
        return CGPointMake(180, _radarYOrigin+175+(rowOrder*50));
    } else {
        rowOrder = order/2;
        return CGPointMake(136, _radarYOrigin+175+(rowOrder*50));
    }
}

- (CGPoint)centerForNearBeacon:(int)order
{
    int rowOrder;
    if (order%2 == 1) {
        rowOrder = (order-1)/2;
        return CGPointMake(255, _radarYOrigin+165+(rowOrder*60));
    } else {
        rowOrder = order/2;
        return CGPointMake(60, _radarYOrigin+165+(rowOrder*60));
    }
}

- (CGPoint)centerForFarBeacon:(int)order
{
    int rowOrder;
    if (order%2 == 1) {
        rowOrder = (order-1)/2;
        return CGPointMake(130+(rowOrder*44), _radarYOrigin+30);
    } else {
        rowOrder = order/2;
        return CGPointMake(130+(rowOrder*44), _radarYOrigin+360);
    }
}

#pragma mark - ESTBeaconManagerDelegate Implementation

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    /*
    NSLog(@"-------Hearing:%u----",[beacons count]);
    NSLog(@"visible:%u",[self.visibleBeacons count]);
    for (UIImageView *beaconView in self.visibleBeacons) {
        NSLog(@"remove");
        [beaconView removeFromSuperview];
    }
    [self.visibleBeacons removeAllObjects];
    */
    
    //[self showBeaconsInformations:beacons];
    self.visibleEstBeacons = beacons;
    for (NSInteger i = 0; i < [self.visibleBeacons count]; i++) {
        if (i < [beacons count]) {
            ESTBeacon *beacon = [beacons objectAtIndex:i];
            
            [beacon readBeaconPowerWithCompletion:^(ESTBeaconPower value, NSError *error) {
                //NSLog(@"beacon power:%d",value);
            }];
            
            //UIImageView *beaconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[beaconImages objectAtIndex:i]]];
            //[self.visibleBeacons addObject:beaconView];
            //[self.beaconContainer addSubview:beaconView];
            //NSLog(@"add beacon:%@",[beacon proximityUUID]);
            //NSLog(@"signal strenght:%@",[beacon power]);
            //NSLog(@"Proximity:%d",beacon.proximity);
            UIButton *beaconView = [self.visibleBeacons objectAtIndex:i];
            beaconView.hidden = NO;
            switch (beacon.proximity) {
                case CLProximityImmediate:
                    //NSLog(@"Immediate");
                    beaconView.center = [self centerForImmediateBeacon:i];
                    break;
                case CLProximityNear:
                    //NSLog(@"Near");
                    beaconView.center = [self centerForNearBeacon:i];
                    break;
                case CLProximityFar:
                    //NSLog(@"Far");
                    beaconView.center = [self centerForFarBeacon:i];
                    break;
                default:
                    //NSLog(@"ERRADO");
                    beaconView.hidden = YES;
                    break;
            }
        } else {
            UIButton *beaconView = [self.visibleBeacons objectAtIndex:i];
            beaconView.hidden = YES;
        }
        /*
        if (beacon.proximity != CLProximityUnknown) {
         
        }
         */
    }
    //NSLog(@"---END--");
    
}

#pragma mark ACTIONS

- (void)trackBeacon:(UIButton *)sender
{
    NSLog(@"beacon clicked:%i",sender.tag);
    
    if (sender.tag < [self.visibleEstBeacons count]) {
        ESTBeacon *selectedBeacon = [self.visibleEstBeacons objectAtIndex:sender.tag];
        NSLog(@"selectedBeacon major:%@",selectedBeacon.major);
        Beacon *beacon = [self.event beaconForEstimoteBeacon:selectedBeacon];
        
        [self performSegueWithIdentifier:HETrackBeaconSegueID sender:beacon];
    }
}

- (BOOL)isValidBeacon:(ESTBeacon *)estBeacon
{
    for (Beacon *beacon in self.event.beacons) {
        if ([estBeacon.proximityUUID.UUIDString isEqualToString:beacon.proxUUID] && [estBeacon.major isEqualToNumber:beacon.majorId] && [estBeacon.minor isEqualToNumber:beacon.minorId]) {
            return YES;
        }
    }
    return NO;
}

-(void)showBeaconsInformations:(NSArray *)beacons
{
    if (_showedBeaconsInfo) return;
    _showedBeaconsInfo = YES;
    
    for (NSInteger i = 0; i < [beacons count]; i++) {
        ESTBeacon *beacon = [beacons objectAtIndex:i];
        NSLog(@"beacon %u",i);
        NSLog(@"uuid:%@",beacon.proximityUUID.UUIDString);
        NSLog(@"major:%@",[beacon major]);
        NSLog(@"minor:%@",[beacon minor]);
        NSLog(@"-----");
    }
}

#pragma mark SEGUES

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:HETrackBeaconSegueID]) {
        HECloseRangeRadarViewController *closeRangeVC = segue.destinationViewController;
        
        closeRangeVC.beacon = sender;
    }
}

@end
