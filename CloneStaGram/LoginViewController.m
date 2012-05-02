//
//  LoginViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "AppDelegate.h"
#import "FBConnect.h"
#import "LoginViewController.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation LoginViewController

@synthesize setLogOut;



#pragma mark - UIView view methods

-(void)viewWillAppear:(BOOL)animated
{
    if( self.setLogOut ){
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[delegate facebook] logout];
    }
    
    //Show login button.
    UIButton *loginButton = (UIButton *)[self.view viewWithTag:100];
    loginButton.hidden = NO;
    
    //Activity indicator should be off.
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:101];
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = [delegate facebook];
    
    //Add logo.
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationBarLogo"]];
    logo.frame = CGRectMake(100,20,logo.frame.size.width, logo.frame.size.height);
    [self.view addSubview:logo];
        
    
    //User logged in?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBID"]){
        
        //We are already logged in.  Go to the FeedViewController.
        [self userIsLoggedIn];
        return;
    }
    
    if (![facebook isSessionValid]) {    
        //do nothing.
    }    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {

    
    //Hide the login button.
    UIButton *loginButton = (UIButton *)[self.view viewWithTag:100];
    loginButton.hidden = YES;
    
    //Start animating activityindicator
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:101];
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];

        
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = [delegate facebook];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [delegate importUsersFollowers:[defaults objectForKey:@"USER_PROFILE_ID"]];
    
    //We have FB credentials now.  Get some FB details about this user.  Then go to (void)request: callback.
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    
    //Loading details about this FB user.  Send the details to Web App and create and/or login this user.
    
    NSLog(@"FACEBOOK RESULT %@ ", result);
    
    NSString * fbid = [result objectForKey:@"id"];
    NSString * email = [result objectForKey:@"email"];
    NSString * name = [result objectForKey:@"name"];

    [self loginOrSignup:name email:email fbid:fbid];
}    

- (void)fbDidNotLogin:(BOOL)cancelled{}
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{}


- (void)fbDidLogout{

    //Remove all the login defaults we saved from Web App.
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

}

- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}





#pragma mark - Web App User Login Methods

/**
  Called after we have Facebook credentials.  Send all the users FB credentials to the web app.
  We create a new user if we don't already have this FB id.  Returns a logged in user.
*/
- (void)loginOrSignup:name email:(NSString *)email fbid:(NSString *)fbid{
    
    //Now pass this to our login
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            name, @"name",
                            email, @"email",
                            fbid, @"fbid",
                            nil];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/login_or_signup/" parameters:params];
    NSLog(@"PARAMS %@", params);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"RESPONSE %@", response);
        NSLog(@"JSON %@", JSON);
        
        NSDictionary *dict = [JSON objectAtIndex:0];
        NSString * fbid = [dict valueForKey:@"fbid"];
        NSString * user_profile_id = [dict valueForKey:@"user_profile_id"];
        NSString * username = [dict valueForKey:@"username"];
        
        NSString * api_key = [dict valueForKey:@"api_key"];
        NSString * api_username = [dict valueForKey:@"api_username"];
        NSString * api_key_string = [NSString stringWithFormat:@"?format=json&username=%@&api_key=%@", api_username, api_key ];
         
        [[NSUserDefaults standardUserDefaults] setObject:fbid forKey:@"FBID"];
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"USERNAME"];
        [[NSUserDefaults standardUserDefaults] setObject:user_profile_id forKey:@"USER_PROFILE_ID"];
        [[NSUserDefaults standardUserDefaults] setObject:api_key_string forKey:@"API_KEY_STRING"];
                
        [self userIsLoggedIn];
        
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // your failure code here
        //NSLog(@"FAILED %@", JSON);
    }];
    [operation start];
    
}


#pragma mark - Methods for handling login/logout.

- (IBAction)clickLoginWithFacebook:(id)sender{
    //Start up the FB stuff.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] authorize:nil];    
}

- (void)logoutThisUser{
    //Logout of FB.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[delegate facebook] logout];
}


/* User logged in successfully. Change the rootviewcontroller from our loginviewcontroller to our appviewcontroller */
- (void)userIsLoggedIn{
    self.setLogOut = FALSE;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.window.rootViewController = delegate.appViewController;
}

@end
