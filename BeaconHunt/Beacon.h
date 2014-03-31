//
//  Beacon.h
//  BeaconHunt
//
//  Created by Roberto Silva on 28/03/14.
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
@property (nonatomic, retain) NSString * farTitle;
@property (nonatomic, retain) NSString * farSubtitle;
@property (nonatomic, retain) NSString * nearTitle;
@property (nonatomic, retain) NSString * nearSubtitle;
@property (nonatomic, retain) NSString * immediateTitle;
@property (nonatomic, retain) NSString * immediateSubtitle;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Event *event;

@end
