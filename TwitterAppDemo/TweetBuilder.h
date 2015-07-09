//
//  TweetBuilder.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 4/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TweetObject;

@protocol TwitterBuilderProtocol <NSObject>

@optional
-(void)loadingTweetsComplete;
-(void)loadingTweetsFailed:(NSError *)error;

@end

@interface TweetBuilder : NSObject

+(TweetBuilder *) sharedObject;
-(void)loadTweetsWithNewScreenName:(NSString *)screenNameArg Delegate:(id <TwitterBuilderProtocol>) delegateArg;
-(BOOL)hasAPreviousTweet;
-(BOOL)hasANextTweet;
-(void) resetScreenName;
-(TweetObject *)getUserInfoTweet;
-(TweetObject *)getNextTweet;
-(TweetObject *)getPreviousTweet;

@property (readonly, nonatomic) BOOL isReady;

@end
