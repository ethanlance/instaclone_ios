//
//  ImageViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewDelegate
@optional
-(void)cancel;
@end

@interface ImageViewController : UIViewController{
    id delegate;
    
    CGFloat lastScale;
    CGFloat firstX;
	CGFloat firstY;
}

@property (nonatomic, assign) id <ImageViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIImageView *selectedImage;

@property (nonatomic, retain) UIImage *image;

//@property (nonatomic, assign) id delegate; 

@end
