//
//  HEBasicTableViewController.h
//  EmailMarketing
//
//  Created by Roberto Silva on 11/09/13.
//  Copyright (c) 2013 Locaweb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEBasicTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak,nonatomic) NSString *blankImageName;

- (void)useRefreshControl;
- (void)toogleBlankScreen;
@end
