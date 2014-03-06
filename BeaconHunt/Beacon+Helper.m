//
//  Beacon+Helper.m
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "Beacon+Helper.h"
#import "NSManagedObject+LocalAccessors.h"
#import <PFQuery.h>

@implementation Beacon (Helper)

/*
+ (void)loadFromServerWithBlock:(void (^)(BOOL success, NSError *errorMessage) )completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
    [query includeKey:@"event"];
    [query whereKey:@"event.finished" equalTo:[NSNumber numberWithBool:NO]];
    [query orderByAscending:@"event.objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d rows.", objects.count);
            // Do something with the found objects
            [Beacon importWithServerData:objects];
            completion(YES,nil);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completion(NO,error);
        }
    }];
}

+ (void)importWithServerData:(NSArray *)beacons
{
    NSArray *previousEvents = [Event orderedList];
    NSMutableArray *currentEvents = [NSMutableArray array];
    
    // Adding/Updating Projects
    Event *event;
    for (PFObject* pfBeacon in beacons) {
        NSLog(@"%@", pfBeacon.objectId);
        PFObject *pfEvent = pfBeacon[@"event"];
        if (![event.uniqueId isEqualToString:pfEvent.objectId]) {
            //New/Updated Event
            event = [Event eventWithParseObject:pfEvent];
            [currentEvents addObject:event];
        }
        
        [Beacon beaconWithParseObject:pfBeacon inEvent:event];
    }
    
    // Removing deleted projects
    for (Event *previousEvent in previousEvents) {
        if (![currentEvents containsObject:previousEvent]) {
            [previousEvent.managedObjectContext deleteObject:previousEvent];
        }
    }
    
    [Beacon saveContext];
    
}
*/
+ (Beacon *)beaconWithParseObject:(PFObject *)pfObject inEvent:(Event *)event
{
    
    
    Beacon *beacon = [Beacon beaconById:pfObject.objectId];
    
    if (!beacon) {
        beacon = [Beacon createInstance];
    }
    
    beacon.uniqueId = pfObject.objectId;
    beacon.event = event;
    beacon.majorId = pfObject[@"majorId"];
    beacon.minorId = pfObject[@"minorId"];
    beacon.minorId = pfObject[@"minorId"];
    //event.name = pfObject[@"name"];
    
    return beacon;
}

+ (Beacon *)beaconWithParseObject:(PFObject *)pfObject
{
    
    
    Beacon *beacon = [Beacon beaconById:pfObject.objectId];
    
    if (!beacon) {
        beacon = [Beacon createInstance];
    }
    
    
    beacon.uniqueId = pfObject.objectId;
    beacon.proxUUID = pfObject[@"proxUUID"];
    beacon.majorId = pfObject[@"majorId"];
    beacon.minorId = pfObject[@"minorId"];
    beacon.password = pfObject[@"password"];
    //event.name = pfObject[@"name"];
    
    return beacon;
}

+ (Beacon *)beaconById:(NSString *)uniqueId
{
    if (!uniqueId) return nil;
    
    NSArray *beaconArray = [Beacon fetchAllWithPredicate:[NSPredicate predicateWithFormat:@"uniqueId = %@", uniqueId]];
    if ([beaconArray count] == 1) {
        return [beaconArray objectAtIndex:0];
    } else {
        return nil;
    }
}

- (BOOL) isEstimoteBeacon:(ESTBeacon *)estimoteBeacon
{
    if ([self.majorId isEqualToNumber:estimoteBeacon.major] && [self.minorId isEqualToNumber:estimoteBeacon.minor]) {
        return YES;
    } else {
        return NO;
    }
}

@end
