//
//  CLONEFirstViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "ImageModel.h"
#import "UserModel.h"
#import "FeedViewController.h"
#import "PersonViewController.h"
#import "LoginViewController.h"

#import "SBJson.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

@implementation FeedViewController

@synthesize imageFeedArray;
@synthesize context;
@synthesize reloadButton;
@synthesize activityButton;
@synthesize activityIndicator;
@synthesize imageIdToLoad;
@synthesize userProfileToLoad;
@synthesize appDelegate;
@synthesize logo;
@synthesize navigationControllerOverride;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
        
    [self setReloadButton];
    
    [self showReloadButton];
    
    [self loadImageFeed];   
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    imageFeedArray = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    logo.hidden = FALSE;
    self.navigationItem.title = @"";
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)setReloadButton
{
    reloadButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                     target:self
                                     action:@selector(reloadFeed:)];  
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] ;
    activityButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator]; 
    
}

-(void)showReloadButton
{
    self.navigationItem.rightBarButtonItem = reloadButton;        
}

-(void)showReloadAnimation
{
    self.navigationItem.rightBarButtonItem = activityButton;
    [activityIndicator startAnimating];
}


- (void)reloadTable
{
    [self loadImageModel];
    [self.tableView numberOfRowsInSection:[self.imageFeedArray count]];
    [self.tableView reloadData];
}

- (void)loadImageModel
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    imageFeedArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageModel" inManagedObjectContext:context];
    [request setEntity:entity];    
    
    NSPredicate * predicate = nil;
    
    if( [imageIdToLoad length] != 0 ){
        predicate = [NSPredicate predicateWithFormat:@"(image_id == %@)", imageIdToLoad];       
        
    }else if ( [userProfileToLoad length] != 0 ){
        predicate = [NSPredicate predicateWithFormat:@"(user_profile_id == %@)", userProfileToLoad];
        
    }else{
        
        UINavigationBar *navBar = [[self navigationController] navigationBar];
        
        //Add INSTAGRAM logo to our Nav Bar.
        logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationBarLogo"]];
        logo.frame = CGRectMake(100,4,logo.frame.size.width, logo.frame.size.height);
        UIImage *backgroundImage = [UIImage imageNamed:@"navigationBarBackgroundRetro"];
        [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];  
        [navBar addSubview:logo];
        
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:sortByName]];   
        
    }
    
    if ( predicate )
        [request setPredicate:predicate];   
    
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        NSLog(@"Sorry error");
    }
    
    [self setImageFeedArray:mutableFetchResults];
    
}

- (void)loadImageFeed
{
    NSString * USER_PROFILE_ID = @"";
    NSString * urlString = @"";
    
    if( self.userProfileToLoad ){ 
        urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL, IMAGEFEED_URL_FOR_USER, self.userProfileToLoad];    
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        USER_PROFILE_ID = [defaults objectForKey:@"USER_PROFILE_ID"];
        urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL, IMAGEFEED_URL_FOR_USER_AND_FOLLOWING, USER_PROFILE_ID];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url ];    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        //Save any new data found in JSON to our core data.
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate importImageFeedData:JSON];
        
        [self showReloadButton];
        
        [self reloadTable];
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // your failure code here
    }];
    
    [self showReloadAnimation];
    
    [operation start];
    
}


-(void)submitLike:(NSIndexPath *)tappedRow
{
    ImageModel *image = [imageFeedArray objectAtIndex:[tappedRow row]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UserModel *user = [appDelegate getUser:[defaults objectForKey:@"USER_PROFILE_ID"]];    
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:tappedRow];
    
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:tappedRow];
    int x = (rectInTableView.size.width / 2) - 50;
    int y = (rectInTableView.size.height / 2) - 50;

    
    //Heart Indicator    
    //UIImageView  * heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    //heart.frame = CGRectMake(x, y, 48, 42);  
    //heart.alpha = 0.8;
    //[[cell contentView]  addSubview:heart];   
    
    //Activity Indicator
    UIActivityIndicatorView *activityIndicatorLike = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x,y, 100, 100)] ;
    [[cell contentView] addSubview:activityIndicatorLike];   
    [activityIndicatorLike startAnimating];
    
    
    NSString * image_uri = [NSString stringWithFormat: @"/api/v1/image/%@/", image.image_id];
    NSString * user_profile_uri = [NSString stringWithFormat:@"/api/v1/user_profile/%@/", user.user_profile_id];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            image_uri, @"image",
                            user_profile_uri, @"user_profile",
                            nil];
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:LIKE_URL parameters:params];

    //I'm not doing something right with AFJSONRequestOperation, the web app wants json request, I don't think I should have to send the json this way.  Fix this.
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];   
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"]; 
    [request setValue:@"application/json"  forHTTPHeaderField:@"Accept"]; 
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSError * error;

        NSString * location =  [[response allHeaderFields] valueForKey:@"Location"];
        
        NSRange textRange;
        NSRange searchRange = NSMakeRange(0, [location length]);        
        textRange = [location rangeOfString:@"/like/none/"
                                         options:NSCaseInsensitiveSearch 
                                           range:searchRange];        
        
        if( textRange.location == NSNotFound ){
            //Save Core Data
            NSInteger amount =[image.like_count integerValue];
            amount++;
            image.like_count = [NSNumber numberWithInteger:amount];
            if (![self.context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedRow] withRowAnimation:UITableViewRowAnimationNone];            
        
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedRow] withRowAnimation:UITableViewRowAnimationNone];            
        // your failure code here
    }];
    
    [operation start]; 
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [imageFeedArray count];
}

-(void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    
	ImageModel *image = [imageFeedArray objectAtIndex:[indexPath row]];
    
    UserModel *user = [appDelegate getUser:image.user_profile_id];
    
    
    //Wire up the Cell fields to our model data.
    //Text:
    UILabel *username1 = (UILabel *)[cell viewWithTag:103];
    UILabel *username2 = (UILabel *)[cell viewWithTag:104];
    username1.userInteractionEnabled = YES;
    username2.userInteractionEnabled = YES;
	username1.text = user.username;
    username2.text = user.username;
    
    
//    username1.tag = [fbid integerValue];
//    username2.tag = [fbid integerValue];

    UITapGestureRecognizer *tapUsername = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUsernameTap:) ];
    [tapUsername setNumberOfTapsRequired:1];    

    UITapGestureRecognizer *tapUsername2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUsernameTap:) ];
    [tapUsername2 setNumberOfTapsRequired:1];    

    
    [username1 addGestureRecognizer:tapUsername];        
    [username2 addGestureRecognizer:tapUsername2];        
    
    UILabel *like = (UILabel *)[cell viewWithTag:105];
    like.text = [NSString stringWithFormat:@"%@ likes",image.like_count];

    //Date:
    UILabel *datetime = (UILabel *)[cell viewWithTag:102];
    datetime.text = image.timeSince;
    
    //Image:
    UIImageView *photo = image.image;
    photo.userInteractionEnabled = YES;
    [photo setTag:101];

    photo.frame = CGRectMake(10, 42, 300, 300);
    [[cell contentView] addSubview:photo];    
    
    //Icon
    UIImageView *usericon = (UIImageView *)[cell viewWithTag:200];
    usericon.image = user.image.image;
    
    
    //Double tap image to LIKE it.
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTap:) ];
    [tapImage setNumberOfTapsRequired:2];
    [photo addGestureRecognizer:tapImage];

    UIButton * likeButton = (UIButton *)[cell viewWithTag:106];
    UITapGestureRecognizer *tapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTap:) ];
    [tapLike setNumberOfTapsRequired:2];
    [likeButton addGestureRecognizer:tapLike];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
//    ImageFeed *data = [imageFeedArray objectAtIndex:[indexPath row]];
//    UIImageView *image = data.image;
    return 420;    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the    object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



#pragma mark - IBActions
//Clicking on an image in Feed View.
//Sent the web app image_id and username.
-(IBAction)handleLikeTap:(UITapGestureRecognizer *)gesture
{
    CGPoint touchLocation = [gesture locationOfTouch:0 inView:self.tableView];
    NSIndexPath *tappedRow = [self.tableView indexPathForRowAtPoint:touchLocation];
    [self submitLike:tappedRow];
}


- (IBAction)handleUsernameTap:(UITapGestureRecognizer *)gesture
{
    
    CGPoint touchLocation = [gesture locationOfTouch:0 inView:self.tableView];
    NSIndexPath *tappedRow = [self.tableView indexPathForRowAtPoint:touchLocation];
   
    ImageModel *image = [imageFeedArray objectAtIndex:[tappedRow row]]; 
    UserModel *user = [appDelegate getUser:image.user_profile_id];
    
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PersonViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"personViewController"];
    
    viewController.userProfileToLoad = user.user_profile_id;
    
    self.navigationItem.title = [NSString stringWithFormat: @"%@", user.username];
    
    logo.hidden = TRUE;
    
    if( navigationControllerOverride ){
        [self.navigationControllerOverride pushViewController:viewController animated:YES];   
    }else{
        [self.navigationController pushViewController:viewController animated:YES];   
    }
}


- (IBAction)reloadFeed:(id)sender
{
    [self loadImageFeed];
}



@end




