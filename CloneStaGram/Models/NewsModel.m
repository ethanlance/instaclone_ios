//
//  News.m
//  CloneStaGram
//
//  Created by Ethan Lance on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsModel.h"


@implementation NewsModel

@dynamic image_id;
@dynamic like_id;
@dynamic datetime;
@dynamic user_profile_id;

-(NSString *)timeSince
{
        
    //NSLog(@"DATETIME %@", self.datetime);
    
    //NSTimeInterval differenceInSeconds = [d timeIntervalSinceNow];    
    NSTimeInterval differenceInSeconds = [[NSDate date] timeIntervalSinceDate:self.datetime];
    
    NSInteger totalSeconds = floor(differenceInSeconds);
    //NSInteger seconds = totalSeconds % 60;
    //NSInteger minutes = totalSeconds / 60;
    NSString *waitTime = 0;
    
    //NSLog(@"sec %i", totalSeconds);
    
    if(totalSeconds < 60){
        waitTime = [NSString stringWithFormat:@"%is", totalSeconds];
    }else if(totalSeconds < 3600){
        waitTime = [NSString stringWithFormat:@"%im", (totalSeconds / 60)];
    }else if(totalSeconds < 86400){
        waitTime = [NSString stringWithFormat:@"%ih", (totalSeconds / 3600)];
    }else{
        waitTime = [NSString stringWithFormat:@"%id", (totalSeconds / 86400)];
    }
    
    //NSLog(@"WAITTIME %@", waitTime);
    return waitTime;
}


@end
