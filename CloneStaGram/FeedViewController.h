//
//  CLONEFirstViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FeedViewController :UITableViewController <UITableViewDataSource, UITableViewDelegate>{
	NSMutableArray *items;
}

- (IBAction)reloadFeed:(id)sender;
- (IBAction)handleLikeTap:(id)sender;
//- (IBAction)clickLike:(id)sender;
- (void)loadImageFeed;
- (void)loadImageModel;
- (void)reloadTable;
- (void)setReloadButton;
- (void)showReloadButton;

@property (nonatomic, strong) NSMutableArray *imageFeedArray;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, retain) UIBarButtonItem *reloadButton;
@property (nonatomic, retain) UIBarButtonItem *activityButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSString *imageIdToLoad;
@property (nonatomic, retain) NSString *userProfileToLoad;
@property (nonatomic, retain) UIImageView *logo;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, retain) UINavigationController *navigationControllerOverride;

@end
