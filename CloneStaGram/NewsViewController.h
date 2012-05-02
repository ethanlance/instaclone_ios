//
//  NewsViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NewsViewController : UITableViewController

- (void)loadNewsFeed;
- (void)reloadTable;
- (void)setReloadButton;
- (void)showReloadButton;



@property (nonatomic, strong) NSMutableArray *newsFeedArray;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, retain) UIBarButtonItem *reloadButton;
@property (nonatomic, retain) UIBarButtonItem *activityButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end
