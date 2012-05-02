//
//  NSObject+UIImage_fixOrientation_h.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
 