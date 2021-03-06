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
#import "Beacon+Helper.h"
#import "HECloseRangeRadarViewController.h"

NSUInteger const HEMaxBeaconsOnScreen = 3;
NSString *const HETrackBeaconSegueID = @"Track Beacon Segue";

@interface HELongRangeRadarViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) NSArray *visibleBeacons;
@property (nonatomic, strong) NSArray *visibleEstBeacons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewVerticalSpaceConstraint;
@property (strong, nonatomic) Beacon *currentBeacon;
@property (weak, nonatomic) IBOutlet UIImageView *immediateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nearImageView;
@property (weak, nonatomic) IBOutlet UIImageView *farImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtextLabel;

@end

@implementation HELongRangeRadarViewController {
    CGFloat _radarYOrigin;
    BOOL _showedBeaconsInfo;
}

#pragma mark - LIFE CYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupInterface];
    self.currentBeacon = [self.event currentBeacon];
    [self showBeaconForProximity:CLProximityUnknown];
    [self setupManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setupInterface
{
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (screenHeight > 480) {
        self.topViewVerticalSpaceConstraint.constant += 44;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(trackBeacon)];
    [self.immediateImageView addGestureRecognizer:tap];
    self.immediateImageView.userInteractionEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    [self.beaconManager stopRangingBeaconsInRegion:region];
}

#pragma mark SETUP ESTIMOTE/BEACONS

- (void)setupManager
{
    NSLog(@"setupManager");
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    //
    [self.beaconManager startMonitoringForRegion:region];
    [self.beaconManager requestStateForRegion:region];
}
/*
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
*/

#pragma mark - ESTBeaconManagerDelegate Implementation

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    NSLog(@"-------Hearing:%u----",[beacons count]);
    
    for (int i = 0; i < [beacons count]; i++) {
        ESTBeacon *beacon = [beacons objectAtIndex:i];
        if ([self.currentBeacon isEstimoteBeacon:beacon]) {
            NSLog(@"current beacon:%i",i);
            [self showBeaconForProximity:beacon.proximity];
        }
    }
}

-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    // iPhone/iPad entered beacon zone
    // present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Você entrou na area do jogo, veja sua dica e comece a caçada.";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    // present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Você está saindo da area do jogo, mas fique tranquilo que iremos te informar quando você voltar";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

#pragma mark ACTIONS

- (void)trackBeacon
{
    [self performSegueWithIdentifier:HETrackBeaconSegueID sender:nil];
}

- (void)showBeaconForProximity:(CLProximity)proximity
{
    self.immediateImageView.hidden = YES;
    self.nearImageView.hidden = YES;
    self.farImageView.hidden = YES;
    
    switch (proximity) {
        case CLProximityImmediate:
            //NSLog(@"Immediate");
            self.immediateImageView.hidden = NO;
            self.mainTextLabel.text = [self.currentBeacon.immediateTitle uppercaseString];
            self.subtextLabel.text = [self.currentBeacon.immediateSubtitle uppercaseString];
            break;
        case CLProximityNear:
            //NSLog(@"Near");
            self.nearImageView.hidden = NO;
            self.mainTextLabel.text = [self.currentBeacon.nearTitle uppercaseString];
            self.subtextLabel.text = [self.currentBeacon.nearSubtitle uppercaseString];
            break;
        case CLProximityFar:
            //NSLog(@"Far");
            self.farImageView.hidden = NO;
            self.mainTextLabel.text = [self.currentBeacon.farTitle uppercaseString];
            self.subtextLabel.text = [self.currentBeacon.farSubtitle uppercaseString];
            break;
        default:
            //NSLog(@"ERRADO");
            self.mainTextLabel.text = [@"Nada por perto!" uppercaseString];
            self.subtextLabel.text = [@"De uma volta e espere por um aviso." uppercaseString];
            
            break;
    }
}
/*
- (void)trackBeacon:(UIButton *)sender
{
    NSLog(@"beacon clicked:%li",(long)sender.tag);
    
    if (sender.tag < [self.visibleEstBeacons count]) {
        ESTBeacon *selectedBeacon = [self.visibleEstBeacons objectAtIndex:sender.tag];
        NSLog(@"selectedBeacon major:%@",selectedBeacon.major);
        Beacon *beacon = [self.event beaconForEstimoteBeacon:selectedBeacon];
        NSLog(@"beacon major:%@",beacon.majorId);
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

- (BOOL)isCurrentBeacon:(ESTBeacon *)estBeacon
{
    if ([estBeacon.proximityUUID.UUIDString isEqualToString:self.currentBeacon.proxUUID] && [estBeacon.major isEqualToNumber:self.currentBeacon.majorId] && [estBeacon.minor isEqualToNumber:self.currentBeacon.minorId]) {
        return YES;
    }
    return NO;
}

-(void)showBeaconsInformations:(NSArray *)beacons
{
    if (_showedBeaconsInfo) return;
    _showedBeaconsInfo = YES;
    
    for (NSInteger i = 0; i < [beacons count]; i++) {
        ESTBeacon *beacon = [beacons objectAtIndex:i];
        NSLog(@"beacon %ld",(long)i);
        NSLog(@"uuid:%@",beacon.proximityUUID.UUIDString);
        NSLog(@"major:%@",[beacon major]);
        NSLog(@"minor:%@",[beacon minor]);
        NSLog(@"-----");
    }
}
*/
#pragma mark SEGUES

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:HETrackBeaconSegueID]) {
        HECloseRangeRadarViewController *closeRangeVC = segue.destinationViewController;
        
        closeRangeVC.beacon = self.currentBeacon;
    }
}

@end
