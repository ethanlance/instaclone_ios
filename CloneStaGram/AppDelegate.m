//
//  CLONEAppDelegate.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AFJSONRequestOperation.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize facebook;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize baseUrl;

@synthesize appViewController;
@synthesize loginViewController;

@synthesize rootFeedViewController;
@synthesize rootPopularViewController;

@synthesize followingSet;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}
 
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after application launch.
    
    
    loginViewController = (LoginViewController *)self.window.rootViewController;
    
    
    // Initialize Facebook
    facebook = [[Facebook alloc] initWithAppId:FBAPPKEY andDelegate:loginViewController];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    appViewController = (UITabBarController *)[myStoryboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    

    //Who does this user follow.
    [self importUsersFollowers:[defaults objectForKey:@"USER_PROFILE_ID"]];
    
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */ 
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Common App Methods.

-(ImageModel *)getImage:(NSString *)image_id{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ImageModel" inManagedObjectContext:[self managedObjectContext]]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"image_id == %@", image_id]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    ImageModel *obj = [results lastObject];
    return obj;
}

-(UserModel *)getUser:(NSString *)user_profile_id{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UserModel" inManagedObjectContext:[self managedObjectContext]]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"user_profile_id == %@", user_profile_id]];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:&error];
    
    UserModel *obj = [results lastObject];
    return obj;
}

/**
* From this list of userprofiles, import the ones we don't have yet into our UserModel.
*/
-(void) importUserProfiles:(NSSet *)userprofiles{

    //userprofiles is set of strings like "/api/v1/user_profile/1/"
    NSString *ids = @"";
    for(id url in userprofiles){
        NSArray *array = [url componentsSeparatedByString:@"/"];
        NSString *upid = [array objectAtIndex:4];
        ids = [NSString stringWithFormat:@"%@%@;", ids, upid];
    }
    ids = [ids substringToIndex:[ids length]-1];
    
    //Now request data from web app:
    NSString * urlString = [NSString stringWithFormat:@"%@api/v1/user_profile/set/%@/?format=json", BASE_URL, ids];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {        
        //NSLog(@"%@", JSON);
        
        //Save or Update UserModel
        NSArray *JObjects = [JSON valueForKey:@"objects"];
        NSError *error;
        int c = [JObjects count];
        for (int i = 0; i < c; i++){    
            NSDictionary *dict = [JObjects objectAtIndex:i];
            
            NSString *user_profile_id = [dict valueForKeyPath:@"id"];
            
            UserModel *userObject = [self getUser:user_profile_id];
            if( userObject == nil ){
                userObject = (UserModel *)[NSEntityDescription insertNewObjectForEntityForName:@"UserModel" inManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext]];
                
                [userObject setValue:user_profile_id forKey:@"user_profile_id"];
                [userObject setValue:[dict valueForKeyPath:@"username"] forKey:@"username"];
                [userObject setValue:[dict valueForKeyPath:@"fbid"] forKey:@"fbid"];
                
                //Save the FB user icon to app.
                NSString * icon_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [dict valueForKey:@"fbid"]];
                NSString * local_icon_url = [self saveRemoteFile:icon_url];
                [userObject setValue:local_icon_url forKey:@"icon"];
            }
            
            
            [userObject setValue:[NSNumber numberWithInt:[[dict valueForKeyPath:@"follower_count"]intValue]]  forKey:@"follower_count"];
            [userObject setValue:[NSNumber numberWithInt:[[dict valueForKeyPath:@"following_count"]intValue]]  forKey:@"following_count"];
            [userObject setValue:[NSNumber numberWithInt:[[dict valueForKeyPath:@"photo_count"]intValue]]  forKey:@"photo_count"];

            //Save
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }

        }

    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {}];
    [operation start];
    
}

-(void)importImageFeedData:(NSArray *)JSON
{
    
    NSArray *JObjects = [JSON valueForKey:@"objects"];
    //NSLog(@"%@", JObjects);
    
    
    //Take all the user_profiles out and then import data on those ones we don't have in UserModel.
    NSSet * userProfiles = [NSSet setWithArray:[JObjects valueForKey:@"user_profile"]];
    [self importUserProfiles:userProfiles];
    
    
    NSError *error;
    bool reload = false;
    for (int i = 0; i < [JObjects count]; i++){
        
        NSDictionary *dict = [JObjects objectAtIndex:i];
        
        NSString *image_id = [dict valueForKeyPath:@"id"];
        
        // Do we have this image?  If not then save it.
        NSObject *obj = [self getImage:image_id];
        if( obj == nil ){
            reload = true;
            
            //Setup insert:
            ImageModel *im = (ImageModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ImageModel" inManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext]];
            
            //Save the image to the local Doc Directory
            NSString *local_image_url = [self saveRemoteFile:[dict valueForKeyPath:@"image"]];            
            
            //Date
            NSString *mydate = [dict valueForKeyPath:@"datetime"];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init]; 
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
            
            NSString * user_profile_id  = [self getUserProfileIdFromUserResourceUri:[dict valueForKeyPath:@"user_profile"]];
            
            [im setValue:image_id forKey:@"image_id"];
            [im setValue:user_profile_id forKey:@"user_profile_id"];
            
            [im setValue:local_image_url forKey:@"image_url"];            
            [im setValue:[dateFormatter dateFromString:mydate] forKey:@"datetime"];
            [im setValue:[dict valueForKeyPath:@"like_count"] forKey:@"like_count"];
            [im setValue:[dict valueForKeyPath:@"comment_count"] forKey:@"comment_count"];
            
            
            //Save
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

- (NSString *) getUserProfileIdFromUserResourceUri:(NSString *)user_resource_uri
{
    NSArray *array = [user_resource_uri componentsSeparatedByString:@"/"];
    NSString *upid = [array objectAtIndex:4];
    return upid;
}

- (void) importUsersFollowers:(NSString *)user_profile_id
{
    //Now request data from web app:
    NSString * urlString = [NSString stringWithFormat:@"%@%@?follower=%@", BASE_URL, FOLLOWING_URL, user_profile_id];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {        
        //NSLog(@"%@", JSON);
            
        //Save or Update UserModel
        NSArray *JObjects = [JSON valueForKey:@"objects"];
        
        NSLog(@"JObjects %@", JObjects);
        
        self.followingSet = [[NSMutableSet alloc] init ];
        int c = [JObjects count];
        for (int i = 0; i < c; i++){    
            NSDictionary *dict = [JObjects objectAtIndex:i];
            
            NSString *id = [dict valueForKey:@"id"];
            NSString *following_uri = [dict valueForKeyPath:@"following"];
            NSString *following_id = [self getUserProfileIdFromUserResourceUri:following_uri];
            
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    id, @"id",
                                    following_id, @"user_profile_id",
                                    nil];
            
            NSLog(@"PARAMS %@", params);
            
            [self.followingSet addObject:params];
            
        }
        
        
        //NSLog(@"FOLLOWINGARRAY %@", self.followingSet);
        
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {}];
    [operation start];
    
}

//Takes remote url (image_url), loads the image and saves it to Document Directory.
//Returns the local URL to this new image.
- (NSString *)saveRemoteFile:(NSString *)image_url
{
    //Make local image name from remote url.
    NSURL *url = [NSURL URLWithString:image_url];
    NSArray *components = [url pathComponents];
    NSString *image_name = [@"/"  stringByAppendingString:[components lastObject]];
    
    //Write remote image to Document Directory.
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:image_name];
    [data writeToFile:path atomically:YES];
    
    return path;
}


@end
