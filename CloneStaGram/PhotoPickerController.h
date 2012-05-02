//
//  CLONESecondViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageViewController.h"
@class CIDetector;

@protocol PhotoPickerDelegate 
@optional
-(void) cancel;
-(void) presentImage:(UIImage *)selectedImage;
@end

@interface PhotoPickerController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageViewDelegate>
{
	IBOutlet UIView *previewView;
	IBOutlet UISegmentedControl *camerasControl;
	AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureVideoDataOutput *videoDataOutput;
	BOOL detectFaces;
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureStillImageOutput *stillImageOutput;
	UIView *flashView;
	UIImage *square;
	BOOL isUsingFrontFacingCamera;
	CIDetector *faceDetector;
	CGFloat beginGestureScale;
	CGFloat effectiveScale;
    
    id delegate;
}

@property (nonatomic, readonly, retain) AVCaptureSession *session;
@property(nonatomic,assign)id <PhotoPickerDelegate> delegate;

- (IBAction)takePicture:(id)sender;
- (IBAction)showLibrary:(id)sender;
- (IBAction)cancel:(id)sender;
- (void) setupAVCapture;
- (void)captureStillImageStart;
- (void)captureStillImageFinished:(UIImage *)image;
@end

