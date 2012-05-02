//
//  PhotoTab.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTab.h"
#import "PhotoPickerController.h"
#import "FeedViewController.h"

@implementation PhotoTab


- (void)cancel
{
    self.tabBarController.selectedIndex = 0;
    [self.tabBarController.selectedViewController viewDidAppear:YES];
    
    UINavigationController *nav = (UINavigationController *) self.tabBarController.selectedViewController;        
    
    [(FeedViewController*) nav.visibleViewController loadImageFeed];    
}

-(void)presentImage:(UIImage *)selectedImage
{
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ImageViewController *photoPostView = (ImageViewController *)[myStoryboard instantiateViewControllerWithIdentifier:@"imageView"];

    photoPostView.delegate = self;
    photoPostView.image = selectedImage; 

    [photoPostView setModalPresentationStyle:UIModalPresentationFullScreen];    
    [self presentViewController:photoPostView animated:YES completion:nil];    
}


- (void)viewWillAppear:(BOOL)animated
{    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PhotoPickerController *cameraView = (PhotoPickerController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"cameraView"];

    cameraView.delegate = self;
    [self presentViewController:cameraView animated:YES completion:nil];
}

@end
