//
//  ViewController.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 1/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TweetObject;

typedef NS_ENUM(NSInteger, TwitterViewStatus) {
    TVDefault,
    TVLoadedTweets,
    TVLoadingTweetsFailed
};

@interface TwitterViewController : UIViewController

-(void)loadTweets;
-(IBAction)swipedRight:(UISwipeGestureRecognizer *)sender;
-(IBAction)swipedLeft:(UISwipeGestureRecognizer *)sender;
-(IBAction)swipedDown:(UISwipeGestureRecognizer *)sender;

@property (readonly, nonatomic) TwitterViewStatus tvStatus;
@property (readonly, strong, nonatomic) NSString *errorMessage;
@property (nonatomic, strong) NSString *screenName;

@end

