//
//  CLONEThirdViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface PopularViewController : UIViewController{
    IBOutlet UIView *contentView;    
}

- (IBAction)reloadFeed:(id)sender;
- (IBAction)handleImageTap:(id)sender;
- (void)setReloadButton;
- (void)showReloadButton;
- (void)loadPopularFeed;

@property (nonatomic, strong) NSMutableArray *popularFeedArray;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, retain) UIBarButtonItem *reloadButton;
@property (nonatomic, retain) UIBarButtonItem *activityButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSString *userProfileToLoad;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) UINavigationController *navigationControllerOverride;

@end
