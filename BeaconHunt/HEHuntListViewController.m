//
//  HEHuntListViewController.m
//  BeaconHunt
//
//  Created by Roberto Silva on 26/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import "HEHuntListViewController.h"
#import <FXKeychain.h>
#import "HERegisterViewController.h"
#import "HELongRangeRadarViewController.h"
#import "Event+Helper.h"
#import "BHEventCell.h"
#import "Beacon+Helper.h"

NSString *const BHRegisterUserSegueID = @"Register User Segue";
NSString *const BHStartHuntSegueID = @"Start Hunt Segue";

@interface HEHuntListViewController ()<BCRegisterUserProtocol>

@end

@implementation HEHuntListViewController

#pragma mark LIFE CYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self hasCredentialsInKeychain]) {
        [self loadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[FXKeychain defaultKeychain] removeObjectForKey:BHUserEmailKey];
    [self loadFromServer];
    /*
    if (![self hasCredentialsInKeychain]) {
        [self performSegueWithIdentifier:BHRegisterUserSegueID sender:self];
    } else {
        [self loadFromServer];
    }
    */
}

#pragma mark SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([segue.identifier isEqualToString:BHRegisterUserSegueID]) {
        HERegisterViewController *registerVC = segue.destinationViewController;
        
        registerVC.delegate = self;
    } else if ([segue.identifier isEqualToString:BHStartHuntSegueID]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Event *event = [self.dataArray objectAtIndex:indexPath.row];
        
        HELongRangeRadarViewController *longRangeVC = segue.destinationViewController;        
        longRangeVC.event = event;
    }
}

#pragma mark CREDENTIALS

- (BOOL)hasCredentialsInKeychain
{
    if ([[FXKeychain defaultKeychain] objectForKey:BHUserEmailKey]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark BCRegisterUserProtocol

- (void)userRegistered
{
    if (![self.presentedViewController isBeingDismissed])
    {
        [self dismissViewControllerAnimated:YES completion:^{
            // Do something
            [self loadFromServer];
        }];
    }
}

#pragma mark TABLE VIEW

- (void)loadFromServer
{
    [Event loadFromServerWithBlock:^(BOOL success, NSError *errorMessage) {
        if (success) {
            [self loadData];
        }
    }];
}

- (void)loadData
{
    self.dataArray = [Event orderedList];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BHEventCell *cell = (BHEventCell *)[tableView dequeueReusableCellWithIdentifier:[BHEventCell identifier] forIndexPath:indexPath];
    
    Event *event = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.eventNameLabel.text = event.name;
    
    return cell;
}

@end
