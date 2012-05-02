//
//  PersonViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "PersonViewController.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation PersonViewController

@synthesize following_id;
@synthesize allReadyFollowing;
@synthesize appDelegate;
@synthesize context;
@synthesize userProfileToLoad;
@synthesize segmentedControl;

@synthesize rootFeedViewController;
@synthesize rootPopularViewController;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set context.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    UserModel *user = [appDelegate getUser:self.userProfileToLoad];
    
    UINavigationBar *navBar = [[self navigationController] navigationBar];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"notepad-tiny.png"] atIndex:0 animated:YES];
    [segmentedControl insertSegmentWithImage:[UIImage imageNamed:@"stickynote-tiny.png"] atIndex:1 animated:YES];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.frame = CGRectMake(120, 10, 90, 25);
    [segmentedControl setMomentary:YES];    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [navBar addSubview:segmentedControl];
    
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];

    rootFeedViewController = [sb instantiateViewControllerWithIdentifier:@"feedViewController"];
    rootFeedViewController.userProfileToLoad = userProfileToLoad;
    rootFeedViewController.view.frame = CGRectMake(0,0,tableView.frame.size.width, tableView.frame.size.height);
    rootFeedViewController.tableView.delegate = self;
    rootFeedViewController.navigationControllerOverride = self.navigationController;

    
    rootPopularViewController = [sb instantiateViewControllerWithIdentifier:@"popularViewController"];
    rootPopularViewController.userProfileToLoad = userProfileToLoad;
    rootPopularViewController.view.frame = CGRectMake(0,0,tableView.frame.size.width, tableView.frame.size.height);
    rootPopularViewController.navigationControllerOverride = self.navigationController;
    
    [self setPhotoView:TRUE];
    
    UIImageView *icon = (UIImageView *)[personView viewWithTag:100];
    icon.image = user.image.image;
     
    
    //Fill in user stats.
    UILabel *photoCount = (UILabel *)[personView viewWithTag:104];
    photoCount.text = [user.photo_count stringValue];
    
    UILabel *followsCount = (UILabel *)[personView viewWithTag:105];
    followsCount.text = [user.following_count stringValue];
    
    UILabel *followerCount = (UILabel *)[personView viewWithTag:106];
    followerCount.text = [user.follower_count stringValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * USER_PROFILE_ID = [defaults objectForKey:@"USER_PROFILE_ID"];
    
    /**
        Does the logged in user follow this user? 
        Yes? -> show 'unfollow'
        NO? -> show 'follow'
        Is the logged in user the same user as this profile?
        Yes? -> hide button
     */
    
    
    allReadyFollowing = FALSE;
    NSMutableSet *following = [appDelegate followingSet];
    for(NSDictionary * params in following){
        NSString * following_profile_id = [params valueForKey:@"user_profile_id"];
        if([following_profile_id intValue] == [self.userProfileToLoad intValue]){
            allReadyFollowing = TRUE;
            self.following_id = [params valueForKey:@"id"];
        }
    }
    
    UILabel *username = (UILabel *)[personView viewWithTag:109];
    username.text = user.username;
    
    followButton = (UIButton *)[personView viewWithTag:108];
    if( [USER_PROFILE_ID intValue] == [self.userProfileToLoad intValue] ){
        followButton.hidden = YES;
    }else{
        if( allReadyFollowing ){
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }else{
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];    
        }
        username.text = user.username;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    //    ImageFeed *data = [imageFeedArray objectAtIndex:[indexPath row]];
    //    UIImageView *image = data.image;
    return 420;    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    int ypos = scrollView.contentOffset.y;    
    int personViewHeight = personView.frame.size.height;
    
    if(ypos > -1 && ypos < personViewHeight){
        int y = personViewHeight - ypos;
        tableView.frame = CGRectMake(0,y,tableView.frame.size.width,tableView.frame.size.height);
        int newy = y - personViewHeight;
        personView.frame = CGRectMake(0,newy, personView.frame.size.width, personView.frame.size.height);            
    }
}

- (void)setPhotoView:(BOOL)popular{
    if(popular){
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:1];
        [tableView addSubview:rootPopularViewController.view];    
    }else{
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:1];
        [tableView addSubview:rootFeedViewController.view]; 
    }
        
}

- (IBAction)segmentAction:(id)sender{
    if( [sender selectedSegmentIndex] == 0){
        [self setPhotoView:TRUE];
    }else{
        [self setPhotoView:FALSE];   
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    segmentedControl.hidden = FALSE;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    segmentedControl.hidden = TRUE;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)doFollowUnfollow{
    
    [followButton setEnabled:FALSE];
    [followButton setAlpha:0.5];
    
    NSString * path = nil;
    NSString * method = nil;
    if( allReadyFollowing ){
        method = @"DELETE";
        path = [NSString stringWithFormat:@"%@%@/", FOLLOWING_URL, self.following_id ];
    }else{
        method = @"POST";
        path = [NSString stringWithFormat:@"%@%", FOLLOWING_URL ];
    }
    
    //Send self.userProfileId to web app.  If logged user is already following him/her then set to unfollow and viceversa.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString * follower_uri = [NSString stringWithFormat:@"/api/v1/user_profile/%@/%@", [defaults objectForKey:@"USER_PROFILE_ID"], [defaults objectForKey:@"API_KEY_STRING"]];
    NSString * following_uri = [NSString stringWithFormat:@"/api/v1/user_profile/%@/%@", self.userProfileToLoad, [defaults objectForKey:@"API_KEY_STRING"]];
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            follower_uri, @"follower",
                            following_uri, @"following",
                            nil];
    
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];    
    NSMutableURLRequest *request = [httpClient requestWithMethod:method path:path parameters:nil];
    
    //I'm not doing something right with AFJSONRequestOperation, the web app wants json request, I don't think I should have to send the json this way.  Fix this.
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];   
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"]; 
    [request setValue:@"application/json"  forHTTPHeaderField:@"Accept"]; 
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) { 
        
        NSString * location =  [[response allHeaderFields] valueForKey:@"Location"];
        NSArray *array = [location componentsSeparatedByString:@"/"];
        self.following_id = [array objectAtIndex:6];        
        
        if( allReadyFollowing ){
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            allReadyFollowing = FALSE;
        }else{
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            allReadyFollowing = TRUE;
        }
        
        [followButton setEnabled:TRUE];
        [followButton setAlpha:1.0];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // your failure code here
        
        //NSLog(@"JSON %@", JSON);
        
        [followButton setTitle:@"Follow" forState:UIControlStateNormal];
        allReadyFollowing = FALSE;
        [followButton setEnabled:TRUE];
        [followButton setAlpha:1.0];
    }];
    
    [operation start]; 
    
}

- (IBAction)handleFollow:(id)sender{    
    [self doFollowUnfollow];
}
@end
