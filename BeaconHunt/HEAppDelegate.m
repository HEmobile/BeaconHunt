//
//  HEAppDelegate.m
//  BeaconHunt
//
//  Created by Roberto Silva on 17/01/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "HEAppDelegate.h"
#import <Parse/Parse.h>

@implementation HEAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark EXPORTS TO PARSe

- (void)exportEventsToParse
{
    //Create Beacons
    PFObject *beacon1 = [PFObject objectWithClassName:@"Beacon"];
    beacon1[@"proxUUID"] = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    beacon1[@"majorId"] = @"13703";
    beacon1[@"minorId"] = @"10228";
    beacon1[@"password"] = @"Eureka1";
    [beacon1 save];
    
    NSLog(@"beacon1:%@",beacon1.objectId);
    
    PFObject *beacon2 = [PFObject objectWithClassName:@"Beacon"];
    beacon2[@"proxUUID"] = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
    beacon2[@"majorId"] = @"36023";
    beacon2[@"minorId"] = @"13959";
    beacon2[@"password"] = @"I win1";
    [beacon2 save];
    
    NSLog(@"beacon2:%@",beacon2.objectId);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:@"mwThXFV9kn" block:^(PFObject *event, NSError *error) {
        // Do something with the returned PFObject in the gameScore variable.
        NSLog(@"%@", event);
        
        [event addObjectsFromArray:@[beacon1,beacon2] forKey:@"beaconList"];
        [event saveInBackground];
    }];
}

#pragma mark LIFE CYCLE

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"hH3VxchL20K3E5mFLCWp1t5C8RtRFWnCIYFKTuYm"
                  clientKey:@"N0iaWxsnSR9EQi2IUl57o1MwwyudeAMPRFugKmPa"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //[self exportEventsToParse];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Database methods

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            if (error != nil) NSLog(@"AppDelegate.saveContext : Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Main" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Main.sqlite"];
    // Remove comment to clear the DB - TODO
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Main_t1:persistentStoreCoordinator.Unresolved error %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Main_t2:persistentStoreCoordinator.Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
