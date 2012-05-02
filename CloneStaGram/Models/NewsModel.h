//
//  News.h
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NewsModel : NSManagedObject

@property (nonatomic, retain) NSString * image_id;
@property (nonatomic, retain) NSString * user_profile_id;

@property (nonatomic, retain) NSString * like_id;
@property (nonatomic, retain) NSDate * datetime;

-(NSString *)timeSince;

@end
