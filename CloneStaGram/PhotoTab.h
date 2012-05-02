//
//  PhotoTab.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickerController.h"
 
@interface PhotoTab : UINavigationController <PhotoPickerDelegate, ImageViewDelegate>

-(void)cancel;

@end
