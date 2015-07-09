//
//  ViewController.m
//  TwitterAppDemo
//
//  Created by Chandima Herath on 1/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import "TwitterViewController.h"
#import "TwitterManager.h"
#import "TweetBuilder.h"
#import "TweetObject.h"

@interface TwitterViewController ()<TwitterBuilderProtocol> {
    BOOL swipingTweet;
    TweetObject *currentTweet;
    UILabel *displayLabel;
}
@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)loadTweets
{
    _tvStatus = TVDefault;
    _errorMessage = @"";
    swipingTweet = true;
    
    [[TweetBuilder sharedObject] loadTweetsWithNewScreenName:_screenName Delegate:self];
}


-(void)loadingTweetsComplete
{
    currentTweet = [[TweetBuilder sharedObject] getUserInfoTweet];
    [self.view addSubview:currentTweet];
    swipingTweet = false;
    
    _tvStatus = TVLoadedTweets;
}


-(void)loadingTweetsFailed:(NSError *)error
{
    _errorMessage = [error.userInfo valueForKey:@"error_info"];
    _tvStatus = TVLoadingTweetsFailed;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)swipedDown:(UISwipeGestureRecognizer *)sender
{
    [TweetObject resetScreenName];
    [[TweetBuilder sharedObject] resetScreenName];
    [[TwitterManager sharedObject] resetScreenName];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)swipedLeft:(UISwipeGestureRecognizer *)sender {
    
    if (!swipingTweet) {
        TweetObject *newTweet;
        
        if([[TweetBuilder sharedObject] hasANextTweet]) {
            newTweet = [[TweetBuilder sharedObject] getNextTweet];
        }else {
            newTweet = nil;
        }
        
        if(newTweet != nil) {
            
            UIView *oldTweet = currentTweet;
            currentTweet = newTweet;
            [self.view addSubview:currentTweet];
            swipingTweet = true;
            
            [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{ [oldTweet setFrame:[currentTweet getOffsetLeftPosition]]; } completion:^(BOOL finished){ swipingTweet = false; [oldTweet removeFromSuperview]; }];
            
            [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{ [currentTweet setFrame:[currentTweet getOffsetCenterPosition]]; } completion:nil];
        }
    }
}


-(IBAction)swipedRight:(UISwipeGestureRecognizer *)sender {
    
    if (!swipingTweet) {
        TweetObject *newTweet;
        
        if([[TweetBuilder sharedObject] hasAPreviousTweet]) {
            newTweet = [[TweetBuilder sharedObject] getPreviousTweet];
        }else {
            newTweet = nil;
        }
        
        if (newTweet != nil) {
            
            UIView *oldTweet = currentTweet;
            currentTweet = newTweet;
            [self.view addSubview:currentTweet];
            swipingTweet = true;
            
            [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{ [oldTweet setFrame:[currentTweet getOffsetRightPosition]]; } completion:^(BOOL finished){ swipingTweet = false; [oldTweet removeFromSuperview]; }];
            
            [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionCurveEaseOut animations:^{ [currentTweet setFrame:[currentTweet getOffsetCenterPosition]]; } completion:nil];
        }
    }
}

@end