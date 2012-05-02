//
//  PersonViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FeedViewController.h"
#import "PopularViewController.h"

@interface PersonViewController : UIViewController <UITableViewDelegate>{
    //FeedViewController *firstController;
    IBOutlet UIView * tableView;
    IBOutlet UIView * personView;
    UIButton *followButton;
}

- (IBAction)handleFollow:(id)sender;


@property (nonatomic, retain) NSString * following_id;
@property (nonatomic) bool allReadyFollowing;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, retain) NSString * userProfileToLoad;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) PopularViewController * rootPopularViewController;
@property (strong, nonatomic) FeedViewController * rootFeedViewController;

@end
