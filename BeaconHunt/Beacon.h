//
//  Beacon.h
//  BeaconHunt
//
//  Created by Roberto Silva on 28/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Beacon : NSManagedObject

@property (nonatomic, retain) NSNumber * found;
@property (nonatomic, retain) NSNumber * majorId;
@property (nonatomic, retain) NSNumber * minorId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * proxUUID;
@property (nonatomic, retain) NSString * uniqueId;
@property (nonatomic, retain) Event *event;

@end
