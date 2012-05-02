//
//  CLONEThirdViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "PopularViewController.h"
#import "AppDelegate.h"
#import "ImageModel.h"
#import "FeedViewController.h"

#import "AFJSONRequestOperation.h"

@implementation PopularViewController

@synthesize popularFeedArray;
@synthesize context;
@synthesize reloadButton;
@synthesize activityButton;
@synthesize activityIndicator;
@synthesize userProfileToLoad;
@synthesize appDelegate;
@synthesize navigationControllerOverride;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Popular";    
    
    [self setReloadButton];
    
    [self showReloadButton];
    
    [self loadPopularFeed];        
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
    
    self.userProfileToLoad = nil;
    
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


-(void) loadImageModel{
    
    popularFeedArray = [[NSMutableArray alloc] init];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageModel" inManagedObjectContext:self.context];
    [request setEntity:entity];    
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"image_id" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByName]];  
    
    NSPredicate * predicate = nil;
    if( self.userProfileToLoad ){
        predicate = [NSPredicate predicateWithFormat:@"(user_profile_id = %@)", self.userProfileToLoad];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"(like_count > 0)"];
    }          
    
    [request setPredicate:predicate];            
        
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
        NSLog(@"Sorry error");
    }
    
    [self setPopularFeedArray:mutableFetchResults];
}

-(void) displayPopularFeed
{
    
    [self loadImageModel];
    
    int padding = 2;
    int w = (CGRectGetWidth(contentView.frame) / 4) - 4;
    int h = w;
    int x = padding;
    int y = padding;
    
    int i = 0;
    for( ImageModel *data in popularFeedArray ){
        

        if(i == 0){
            i++;
        }else if(i == 4){
            i = 0;
            x = padding;
            y = y + h + padding;
        }else{
            i++;
            x = x + w + (padding * 2);
        }
                
        //NSLog(@"x:%i y:%i h:%i w:%i", x,y,w,h);
           
        UIImageView *image = data.image;
        image.userInteractionEnabled = YES;
        image.frame = CGRectMake(x, y, w, h);  
        image.tag = [data.image_id integerValue];
        
        
        //Double tap image to LIKE it.
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:) ];
        [singleTap setNumberOfTapsRequired:1];
        
        [image addGestureRecognizer:singleTap];        
                
        [contentView addSubview:image];
    }
}

- (void)loadPopularFeed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * urlString = @"";
    
    if( self.userProfileToLoad ){
        urlString = [NSString stringWithFormat:@"%@%@%@&user_profile_id=%@", BASE_URL, IMAGEFEED_URL_FOR_USER, [defaults objectForKey:@"API_KEY_STRING"], self.userProfileToLoad]; 
    }else{
        urlString = [NSString stringWithFormat:@"%@%@%@", BASE_URL, IMAGEFEED_URL_FOR_POPULAR, [defaults objectForKey:@"API_KEY_STRING"] ];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        //Save any new data found in JSON to our core data.
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate importImageFeedData:JSON];
        
        [self displayPopularFeed];
        
        [self showReloadButton];
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {}];
    
    [self showReloadAnimation];
    
    [operation start];    
    
}



 

#pragma mark - IBActions
- (IBAction)reloadFeed:(id)sender
{
    [self loadPopularFeed];
}

- (IBAction)handleImageTap:(id)sender
{
    int image_id = [(UIGestureRecognizer *)sender view].tag;
    //NSLog(@"TAP %i", image_id);
    
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FeedViewController* viewController = [sb instantiateViewControllerWithIdentifier:@"feedViewController"];
    
    viewController.imageIdToLoad = [NSString stringWithFormat:@"%i", image_id];
    
    if( navigationControllerOverride ){
        [self.navigationControllerOverride pushViewController:viewController animated:YES];
    }else{
        [self.navigationController pushViewController:viewController animated:YES];
    }    
    
}



@end
