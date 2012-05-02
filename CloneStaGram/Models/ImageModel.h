//
//  ImageFeed.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageModel : NSManagedObject

@property (nonatomic, retain) NSString * image_id;
@property (nonatomic, retain) NSString * user_profile_id;

@property (nonatomic, retain) NSString * image_url;
//@property (nonatomic, retain) NSString * local_image_url;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSNumber * comment_count;
@property (nonatomic, copy) UIImageView * image;


-(NSString *)timeSince;

//-(NSString *)remoteURLtoLocalURL:(NSString *)image_url;


@end
