//
//  ViewController.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 1/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TweetObject;

@interface TwitterViewController : UIViewController

-(IBAction)swipedRight:(UISwipeGestureRecognizer *)sender;
-(IBAction)swipedLeft:(UISwipeGestureRecognizer *)sender;
-(IBAction)swipedDown:(UISwipeGestureRecognizer *)sender;

@end

