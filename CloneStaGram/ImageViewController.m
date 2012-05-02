//
//  ImageViewController.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "constants.h"
#import "ImageViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "FeedViewController.h" 
#import "PhotoPickerController.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Scale.h"


@implementation ImageViewController


@synthesize image, selectedImage, delegate=_delegate;



-(void)viewDidLoad
{
    [super viewDidLoad];    
    selectedImage.image = self.image;
 }

- (void) cancel
{
    [self.delegate cancel];
}


-(IBAction)cancel:(id)sender
{
    [[super presentingViewController] dismissViewControllerAnimated:YES completion:^(void){
        [self cancel];
    }];
}


-(IBAction)accept:(id)sender
{ 
    
    //Category to resize our image before post.  Let's make it smaller.
    CGSize size = CGSizeMake(320,480);
    UIImage *picture = [self.selectedImage.image resizedImage:size interpolationQuality:3];
    
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@", (__bridge NSString *)uuidString, @".jpeg"];
    CFRelease(uuidString);    
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    //Send the logged in users fbid.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * fbid = [defaults objectForKey:@"FBID"];
    
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:fbid, @"fbid", nil];

    NSData *imageData = UIImageJPEGRepresentation(picture, 1);
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload/" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData 
            appendPartWithFileData:imageData 
            name:@"avatar" 
            fileName:uniqueFileName 
            mimeType:@"image/jpeg"];
    }];
    
    //Block callback
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
 
        NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        //Close modal.
        [[super presentingViewController] dismissViewControllerAnimated:YES completion:^(void){
            [self.delegate cancel];
        }];
         
    }];
    [operation start]; 
}

 @end
