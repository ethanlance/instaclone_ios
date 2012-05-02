//
//  UserModel.h
//  CloneStaGram
//
//  Created by Ethan Lance on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserModel : NSManagedObject
@property (nonatomic, copy) UIImageView * image;

@property (nonatomic, retain) NSString * user_profile_id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * photo_count;
@property (nonatomic, retain) NSNumber * follower_count;
@property (nonatomic, retain) NSNumber * following_count;
@property (nonatomic, retain) NSString * fbid;
@property (nonatomic, retain) NSString * icon;

@end
