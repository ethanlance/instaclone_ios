//
//  CLONEAppDelegate.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "ImageModel.h"
#import "NewsModel.h"
#import "UserModel.h"
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarDelegate>{
    Facebook *facebook;
    UITabBarController *appViewController;
}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSURL *baseUrl;

@property (strong, nonatomic) UITabBarController * appViewController;
@property (strong, nonatomic) LoginViewController * loginViewController;

@property (strong, nonatomic) UIViewController * rootFeedViewController;
@property (strong, nonatomic) UIViewController * rootPopularViewController;

@property (nonatomic, strong, retain) NSMutableSet *followingSet;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (ImageModel *)getImage:(NSString *)image_id;
- (UserModel *)getUser:(NSString *)user_id;
- (void) importUserProfiles:(NSSet *)userprofiles;
- (void) importImageFeedData:(NSArray *)JSON;
- (void) importUsersFollowers:(NSString *)user_profile_id;
- (NSString *) getUserProfileIdFromUserResourceUri:(NSString *)user_resource_uri;

@end
