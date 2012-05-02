//
//  NewsViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "AppDelegate.h"

#import "NewsModel.h"
#import "ImageModel.h"

#import "NewsViewController.h"
#import "FeedViewController.h"
#import "PersonViewController.h"
#import "AFJSONRequestOperation.h"

@implementation NewsViewController

@synthesize newsFeedArray;
@synthesize context;
@synthesize reloadButton;
@synthesize activityButton;
@synthesize activityIndicator;
@synthesize appDelegate;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setReloadButton];
    
    [self showReloadButton];
    
    self.navigationItem.title = @"News";
            
    [self loadNewsFeed];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [newsFeedArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
	NewsModel *data = [newsFeedArray objectAtIndex:[indexPath row]];
    
    ImageModel *obj = [appDelegate getImage:data.image_id];
        
    UIImageView *image = obj.image;
    image.userInteractionEnabled = YES;
    image.frame = CGRectMake(10,5,50,50);  
    image.tag = [data.image_id integerValue];
    
    //Double tap image to LIKE it.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:) ];
    [singleTap setNumberOfTapsRequired:1];    
    [image addGestureRecognizer:singleTap];        
    
    [cell addSubview:image];
    
    UserModel *user = [appDelegate getUser:data.user_profile_id];
    
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.text = [user.username stringByAppendingString:@" liked your photo."];
    label.frame = CGRectMake(100,5,200,20);
    [label setFont:[UIFont fontWithName:@"Arial" size:10]];
    
    UITapGestureRecognizer *tapUsername = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUsernameTap:) ];
    [tapUsername setNumberOfTapsRequired:1];    
    
    [label addGestureRecognizer:tapUsername];        
    [cell addSubview:label];

    UILabel *timesince = [[UILabel alloc] init];
    timesince.text = [data.timeSince stringByAppendingString:@"'s ago"];
    timesince.frame = CGRectMake(100,30,200,10);
    timesince.font = [UIFont fontWithName:@"Arial" size:11 ];
    timesince.textColor = [UIColor grayColor];
    [cell addSubview:timesince];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    return 60;    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



-(NSArray *)getNews:(NSString *)like_id{
    NSError *error;
    //Fetch this image_id.  Is it already saved?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsModel" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
        
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count] == 1)
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;    
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

-(NSString *)uriToId:(NSString *)uri{
    NSArray *array = [uri componentsSeparatedByString:@"/"];
    return [array objectAtIndex:4];
}

-(void)importNewsFeedData:(NSArray *)JSON
{
    
    //NSLog(@"JSON %@", JSON);

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    
    NSArray *JObjects = [JSON valueForKey:@"objects"];
    
    if( [JObjects count] > 0){
    
        NSSet * userProfiles = [NSSet setWithArray:[JObjects valueForKey:@"user_profile"]];
        [appDelegate importUserProfiles:userProfiles];    
        
        NSError *error;
        int c = [JObjects count];
        for (int i = 0; i < c; i++){     
        
            NSDictionary *dict = [JObjects objectAtIndex:i];
            
            NSLog(@"DICT %@", dict);
            
            if( dict ){
                
                NSLog(@"IMAGE %@", [dict valueForKey:@"image"]);
                
                NSString *image_id = [self uriToId:[dict valueForKeyPath:@"image"]];
                NSString *user_profile_id = [self uriToId:[dict valueForKeyPath:@"user_profile"]];
                NSString * like_id = [dict valueForKeyPath:@"id"];
                
                NSObject *obj = [self getNews:like_id];
                 
                
                //If this image_id is not found in our data, then save it:
                if( obj == nil ){
                    
                    //Setup insert:
                    NewsModel *newsModel = (NewsModel *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsModel" inManagedObjectContext:self.context];
                    
                    //Date
                    NSString *mydate = [dict valueForKeyPath:@"datetime"];
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init]; 
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
                    
                    [newsModel setValue:image_id forKey:@"image_id"];
                    [newsModel setValue:like_id forKey:@"like_id"];            
                    [newsModel setValue:[dateFormatter dateFromString:mydate] forKey:@"datetime"];
                    [newsModel setValue:user_profile_id forKey:@"user_profile_id"];
                    
                    //Save
                    if (![self.context save:&error]) {
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
            }
        }
        [self reloadTable];
    }
}

- (void)reloadTable
{   
    [self loadNewsModel];
    [self.tableView numberOfRowsInSection:[self.newsFeedArray count]];
    [self.tableView reloadData];
}

-(void)loadNewsModel
{
    newsFeedArray = [[NSMutableArray alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NewsModel" inManagedObjectContext:context];
    
    [request setEntity:entity];    
    
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByName]];   
    
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        NSLog(@"Sorry error");
    }
    
    [self setNewsFeedArray:mutableFetchResults];
    
}

- (void)loadNewsFeed
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * USER_PROFILE_ID = [defaults objectForKey:@"USER_PROFILE_ID"];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@%@&user_profile_id=%@", BASE_URL, NEWS_URL, [defaults objectForKey:@"API_KEY_STRING"], USER_PROFILE_ID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        //Save any new data found in JSON to our core data.
        [self importNewsFeedData:JSON];
        
        [self showReloadButton];
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { }];
    
    [self showReloadAnimation];
    
    [operation start];
    
    
}

- (IBAction)reloadFeed:(id)sender
{
    [self loadNewsFeed];
}

- (IBAction)handleImageTap:(UIGestureRecognizer *)gesture{

    CGPoint touchLocation = [gesture locationOfTouch:0 inView:self.tableView];
    NSIndexPath *tappedRow = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    ImageModel *image = [newsFeedArray objectAtIndex:[tappedRow row]]; 
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FeedViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"feedViewController"];
    
    viewController.imageIdToLoad = [NSString stringWithFormat:@"%i", image.image_id];
    [self.navigationController pushViewController:viewController animated:YES];
    
}


- (IBAction)handleUsernameTap:(UIGestureRecognizer *)gesture
{
    
    CGPoint touchLocation = [gesture locationOfTouch:0 inView:self.tableView];
    NSIndexPath *tappedRow = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    ImageModel *image = [newsFeedArray objectAtIndex:[tappedRow row]]; 
     
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PersonViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"personViewController"];
    
    viewController.userProfileToLoad = image.user_profile_id;
    [self.navigationController pushViewController:viewController animated:YES];   
}


@end
