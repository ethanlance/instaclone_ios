//
//  ImageFeed.m
//  CloneStaGram
//
//  Created by Ethan Lance on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageModel.h"


@implementation ImageModel

@dynamic image_id;
@dynamic user_profile_id;

@dynamic image_url;
//@dynamic local_image_url;
@dynamic datetime;
@dynamic like_count;
@dynamic comment_count;

@dynamic image;
 
////Takes remote url (image_url), loads the image and saves it to Document Directory.
////Returns the local URL to this new image.
//- (NSString *)remoteURLtoLocalURL:(NSString *)image_url
//{
//    //Make local image name from remote url.
//    NSURL *url = [NSURL URLWithString:image_url];
//    NSArray *components = [url pathComponents];
//    NSString *image_name = [@"/"  stringByAppendingString:[components lastObject]];
//    
//    //Write remote image to Document Directory.
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    path = [path stringByAppendingString:image_name];
//    [data writeToFile:path atomically:YES];
//    
//    return path;
//}

//-(NSString *)local_image_url
//{
// return [self remoteURLtoLocalURL:self.image_url];   
//}

-(UIImageView *)image
{
    NSData *jpgData = [NSData dataWithContentsOfFile:self.image_url];
    return [[UIImageView alloc] initWithImage:[UIImage imageWithData:jpgData]];
}

-(NSString *)timeSince
{
    
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
