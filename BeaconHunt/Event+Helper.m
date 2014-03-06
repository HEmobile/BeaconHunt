//
//  Event+Helper.m
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "Event+Helper.h"
#import "NSManagedObject+LocalAccessors.h"
#import "Beacon+Helper.h"
#import <PFQuery.h>

@implementation Event (Helper)

+ (NSArray *)orderedList
{
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil];
    
    NSArray *events = [Event fetchAllWithSortDescriptors:sortDescriptors];
    if ([events count] > 0) {
        return events;
    } else {
        return nil;
    }
}

+ (void)loadFromServerWithBlock:(void (^)(BOOL success, NSError *errorMessage) )completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"beacons"];
    //[query whereKey:@"finished" equalTo:[NSNumber numberWithBool:NO]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d rows.", objects.count);
            // Do something with the found objects
            [Event importWithServerData:objects];
            completion(YES,nil);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completion(NO,error);
        }
    }];
}

+ (void)importWithServerData:(NSArray *)objects
{
    NSArray *previousEvents = [Event orderedList];
    NSMutableArray *currentEvents = [NSMutableArray array];
    
    // Adding/Updating Projects
    for (PFObject* object in objects) {
        NSLog(@"%@", object.objectId);
        NSLog(@"beacons:%@",object[@"beacons"]);
        
        [currentEvents addObject:[Event eventWithParseObject:object]];
    }
    
    // Removing deleted projects
    for (Event *previousEvent in previousEvents) {
        if (![currentEvents containsObject:previousEvent]) {
            [previousEvent.managedObjectContext deleteObject:previousEvent];
        }
    }
    
    [Event saveContext];
    
}

+ (Event *)eventWithParseObject:(PFObject *)pfObject
{
    
    
    Event *event = [Event eventById:pfObject.objectId];
    
    if (!event) {
        event = [Event createInstance];
    }
    
    event.uniqueId = pfObject.objectId;
    event.name = pfObject[@"name"];
    
    
    //NSArray *beacons = pfObject[@"beacons"];
    if ([pfObject[@"beacons"] isKindOfClass:[NSArray class]]) {
        [event updateBeacons:pfObject[@"beacons"]];
    }
    
    return event;
}

- (void)updateBeacons:(NSArray *)pfBeaconsArray
{
    NSArray *previousBeacons = [self.beacons allObjects];
    NSMutableSet *currentBeacons = [NSMutableSet set];
    
    // Adding/Updating Projects
    for (PFObject* pfBeacon in pfBeaconsArray) {
        [currentBeacons addObject:[Beacon beaconWithParseObject:pfBeacon inEvent:self]];
    }
    
    // Removing deleted projects
    for (Beacon *previousBeacon in previousBeacons) {
        if (![currentBeacons containsObject:previousBeacon]) {
            [previousBeacon.managedObjectContext deleteObject:previousBeacon];
        }
    }
    
    [self addBeacons:[currentBeacons copy]];
}


+ (Event *)eventById:(NSString *)uniqueId
{
    if (!uniqueId) return nil;
    
    NSArray *eventArray = [Event fetchAllWithPredicate:[NSPredicate predicateWithFormat:@"uniqueId = %@", uniqueId]];
    if ([eventArray count] == 1) {
        return [eventArray objectAtIndex:0];
    } else {
        return nil;
    }
}

- (Beacon *)beaconForEstimoteBeacon:(ESTBeacon *)estBeacon
{
    for (Beacon *beacon in self.beacons) {
        if ([beacon isEstimoteBeacon:estBeacon]) {
            return beacon;
        }
    }
    
    return nil;
}

@end
