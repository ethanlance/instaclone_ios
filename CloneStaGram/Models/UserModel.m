//
//  UserModel.m
//  CloneStaGram
//
//  Created by Ethan Lance on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserModel.h"


@implementation UserModel

@dynamic user_profile_id;
@dynamic username;
@dynamic photo_count;
@dynamic follower_count;
@dynamic following_count;
@dynamic fbid;
@dynamic image;
@dynamic icon;

-(UIImageView *)image
{ 
    NSData *jpgData = [NSData dataWithContentsOfFile:self.icon];
    return [[UIImageView alloc] initWithImage:[UIImage imageWithData:jpgData]];
}


@end
