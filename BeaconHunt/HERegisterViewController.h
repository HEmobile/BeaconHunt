//
//  HERegisterViewController.h
//  BeaconHunt
//
//  Created by Roberto Silva on 26/02/14.
//  Copyright (c) 2014 HE:mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BCRegisterUserProtocol <NSObject>
- (void)userRegistered;
@end

@interface HERegisterViewController : UIViewController
@property (nonatomic, weak) id<BCRegisterUserProtocol> delegate;
@end
