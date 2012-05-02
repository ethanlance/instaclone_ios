//
//  constants.h
//  CloneStaGram
//
//  Created by Ethan Lance on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef CloneStaGram_constants_h
#define CloneStaGram_constants_h

//#define BASE_URL @"http://instaclone.herokuapp.com/"
#define BASE_URL @"http://lancebook.local:8000/"

#define IMAGEFEED_URL_FOR_USER_AND_FOLLOWING @"api/v1/image/?format=json&followers=1&user_profile_id="

#define IMAGEFEED_URL_FOR_USER @"api/v1/image/?format=json&user_profile_id="

#define IMAGEFEED_URL_FOR_POPULAR @"api/v1/popular/?format=json"

#define LIKE_URL @"api/v1/like/"

#define NEWS_URL @"api/v1/news/?format=json&user_profile_id="

#define FOLLOWING_URL @"api/v1/following/"

#define FBAPPKEY @"327806973947395"


#endif
