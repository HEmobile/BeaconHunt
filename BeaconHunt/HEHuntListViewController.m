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

NSString *const BHRegisterUserSegueID = @"Register User Segue";

@interface HEHuntListViewController ()<BCRegisterUserProtocol>

@end

@implementation HEHuntListViewController

#pragma mark LIFE CYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self hasCredentialsInKeychain]) {
        [self performSegueWithIdentifier:BHRegisterUserSegueID sender:self];
    }
}

#pragma mark SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:BHRegisterUserSegueID]) {
        HERegisterViewController *registerVC = segue.destinationViewController;
        
        registerVC.delegate = self;
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
        }];
    }
}

@end
