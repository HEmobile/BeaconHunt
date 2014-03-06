//
//  BHEventCell.h
//  BeaconHunt
//
//  Created by Roberto Silva on 27/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHEventCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
+ (NSString *)identifier;
@end
