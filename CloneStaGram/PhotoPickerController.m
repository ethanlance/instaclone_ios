/*
 File: SqareCamViewController.m
 Abstract: Dmonstrates iOS 5 features of the AVCaptureStillImageOutput class
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "PhotoPickerController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FeedViewController.h"
#import "UIImage+Utilities.h"

#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f


@implementation PhotoPickerController

@synthesize session;
@synthesize delegate=_delegate;


#pragma mark -
#pragma mark View 


- (void)viewDidLoad
{    
    [super viewDidLoad];
    [self setupAVCapture]; 
    
    self.navigationItem.title = @"Camera Mode";
}

- (void)viewDidUnload
{
    previewView = nil;
    previewLayer = nil;
    
    [super viewDidUnload];
    
}

- (void) viewWillAppear:(BOOL)animated  
{
    self.tabBarController.selectedIndex = 0;
    [self.tabBarController.selectedViewController viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    previewLayer.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated]; 
    [session startRunning];
    previewLayer.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //[stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage"];     
    [session stopRunning];
}

- (void) cancel
{
    [self.delegate cancel];
}

- (void) goToImageView:(UIImage *)image
{
    [[super presentingViewController] dismissViewControllerAnimated:YES completion:^(void){
        [self.delegate presentImage:image];
    }];
}


#pragma mark -
#pragma mark Video Capture

- (void)setupAVCapture
{ 
	NSError *error = nil;
	
	session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	
    isUsingFrontFacingCamera = NO;
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];
    
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    previewView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,44.0f, 320.0f, 372.0f)];
    previewView.backgroundColor = [UIColor blackColor];
    [[self view] addSubview:previewView];
    
    
    CGRect bounds = previewView.bounds;
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    previewLayer.frame = bounds;
    previewLayer.hidden = YES;
    
    if (previewLayer.isOrientationSupported) {
        [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [previewView.layer addSublayer:previewLayer];    
}


// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil 
												  cancelButtonTitle:@"Dismiss" 
												  otherButtonTitles:nil];
		[alertView show];
		//[alertView release];
	});
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}



-(void)captureStillImageStart
{
    // Find out the current orientation and tell the still image output.
    effectiveScale = 1.0;
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
	
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]]; 
	
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
          completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
              if (error) {
                  [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
              }
              else {
                  
                  // trivial simple JPEG case
                  NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                  
                  //Pass it on.
                  [self captureStillImageFinished:[UIImage imageWithData:jpegData]];
              }
          }
	 ];
}

- (void)captureStillImageFinished:(UIImage *)image {    
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGRect cropRect;
    if (height > width) {
        cropRect = CGRectMake((height - width) / 2.0f, 0.0f, width, width);
    } else {
        cropRect = CGRectMake((width - height) / 2.0f, 0.0f, width, width);
    }
    
    UIImage *croppedImage = [image croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:image.imageOrientation];
    
    [self goToImageView:resizedImage];
}



#pragma mark -
#pragma mark Image Picker Controller

- (void)showImagePicker
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    [self presentModalViewController:imagePicker animated:YES];    
}

- (void)hideImagePickerAnimated:(BOOL)animated 
{
    [self dismissModalViewControllerAnimated:animated];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
    [self hideImagePickerAnimated:YES];
}

// Image has been picked.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{

    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    cropRect = [originalImage convertCropRect:cropRect];
    
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
    
    ImageViewController *controller = [[ImageViewController alloc] init];
    controller.image = resizedImage;
    [self.navigationController pushViewController:controller animated:YES];
    
    [self hideImagePickerAnimated:NO];
    
    [self goToImageView:resizedImage];    
}





#pragma mark -
#pragma mark Toolbar Actions

- (IBAction)cancel:(id)sender
{
    [[super presentingViewController] dismissViewControllerAnimated:YES completion:^(void){
        [self cancel];
    }];
}

- (IBAction)showLibrary:(id)sender
{
    previewLayer.hidden = YES;
    [session stopRunning];    
    [self showImagePicker];
}

- (IBAction)takePicture:(id)sender
{
    [self captureStillImageStart];
}

@end




















