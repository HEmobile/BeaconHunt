//
//  Beacon+Helper.h
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "Beacon.h"
#import "Event.h"
#import <PFObject.h>
#import <ESTBeacon.h>

@interface Beacon (Helper)
//+ (void)loadFromServerWithBlock:(void (^)(BOOL success, NSError *errorMessage) )completion;
+ (Beacon *)beaconWithParseObject:(PFObject *)pfObject inEvent:(Event *)event;
+ (Beacon *)beaconWithParseObject:(PFObject *)pfObject;
- (BOOL) isEstimoteBeacon:(ESTBeacon *)estimoteBeacon;
@end
