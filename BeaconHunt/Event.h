//
//  Event.h
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Beacon;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * finished;
@property (nonatomic, retain) NSSet *beacons;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addBeaconsObject:(Beacon *)value;
- (void)removeBeaconsObject:(Beacon *)value;
- (void)addBeacons:(NSSet *)values;
- (void)removeBeacons:(NSSet *)values;

@end
