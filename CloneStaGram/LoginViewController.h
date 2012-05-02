//
//  LoginViewController.h
//  CloneStaGram
//
//  Created by Ethan Lance on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface LoginViewController : UIViewController <FBRequestDelegate,FBSessionDelegate>
 
@property BOOL setLogOut;

- (IBAction)clickLoginWithFacebook:(id)sender;

@end
