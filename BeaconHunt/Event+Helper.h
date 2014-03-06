//
//  Event+Helper.h
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "Event.h"
#import <PFObject.h>
#import <ESTBeacon.h>

@interface Event (Helper)
+ (Event *)eventById:(NSString *)uniqueId;
+ (void)loadFromServerWithBlock:(void (^)(BOOL success, NSError *errorMessage) )completion;
+ (NSArray *)orderedList;
+ (Event *)eventWithParseObject:(PFObject *)pfObject;
- (Beacon *)beaconForEstimoteBeacon:(ESTBeacon *)estBeacon;
@end
