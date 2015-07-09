//
//  TweetManager.m
//  TwitterAppDemo
//
//  Created by Chandima Herath on 4/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import "TweetBuilder.h"
#import "TwitterManager.h"

static TweetBuilder *tweetBuilder;

@interface TweetBuilder()<TwitterManagerProtocol> {
    
    BOOL newScreenName;
    BOOL nextTweetsLoaded;
    NSInteger tweetIndex;
    NSInteger timelineIndex;
    
    NSString *screenName;
    NSMutableArray *tweetArray;
    id <TwitterBuilderProtocol> delegate;
}

@end

@implementation TweetBuilder


//This creates a singleton object
+(TweetBuilder *) sharedObject
{
    if(tweetBuilder == nil) {
        tweetBuilder = [[TweetBuilder alloc] init];
    }
    return tweetBuilder;
}


-(id)init
{
    if (self = [super init]) {
        
        tweetIndex = -1;
        _isReady = true;
        newScreenName = true;
        timelineIndex = 0;
        nextTweetsLoaded = true;
    }
    return self;
}


//Loads tweets using the TwitterManager given a Username
-(void)loadTweetsWithNewScreenName:(NSString *)screenNameArg Delegate:(id <TwitterBuilderProtocol>) delegateArg
{
    if(_isReady) {
        
        tweetIndex = -1;
        _isReady = false;
        timelineIndex = 0;
        newScreenName = true;
        nextTweetsLoaded = true;
        tweetArray = nil;
        screenName = screenNameArg;
        delegate = delegateArg;
        
        if (screenName != nil) {
            [[TwitterManager sharedObject] getUserTimeLine:screenName delegate:self];
        }
    }
}


-(NSDictionary *)getUserInfoTweet
{
    if(_isReady) {
        
        if (screenName != nil) {
            return tweetArray[0];
        }else {
            NSLog(@"No Screen Name, Set screen name first");
        }
    }
    //NSLog(@"Busy");
    return nil;
}


-(NSDictionary *)getNextTweet
{
    if(_isReady) {
        
        if(screenName != nil) {
            
            tweetIndex++;
            
            if ((tweetIndex == 20) ||(tweetIndex == 19)) {
                tweetIndex++;
            }
            
            if (!(tweetIndex < [tweetArray count])) {
                tweetIndex = [tweetArray count] - 1;
            }
            
            NSDictionary *tweet = tweetArray[tweetIndex];
            
            if (tweetIndex == ([tweetArray count] - 6)) {
                
                if(!nextTweetsLoaded) {
                    timelineIndex++;
                }
                
                nextTweetsLoaded = true;
                [[TwitterManager sharedObject] setTimeLineIndex:timelineIndex];
                
                if([[TwitterManager sharedObject] hasMoreTweets]) {
                    [[TwitterManager sharedObject] loadNextTweets];
                }
            }
            
            return tweet;
            
        }else {
            
            NSLog(@"No Screen Name, Set screen name first");
        }
    }
    //NSLog(@"Busy");
    return nil;
}


-(NSDictionary *)getPreviousTweet
{
    
    if(_isReady) {
        
        if(screenName != nil) {
            
            tweetIndex--;
            
            if ((tweetIndex == 20) || (tweetIndex == 19)) {
                tweetIndex--;
            }
            
            if(tweetIndex < 0) {
                tweetIndex = 0;
            }
            NSDictionary *tweet = tweetArray[tweetIndex];
            
            if (tweetIndex == 5) {
                
                if(nextTweetsLoaded) {
                    timelineIndex--;
                }
                
                if(timelineIndex < 0) {
                    timelineIndex = 0;
                }else {
                    nextTweetsLoaded = false;
                }
                
                
                [[TwitterManager sharedObject] setTimeLineIndex:timelineIndex];
                
                if([[TwitterManager sharedObject] hasPreviousTweets]) {
                                        
                    
                    [[TwitterManager sharedObject] loadPreviousTweets];
                }
            }
            
            return tweet;
            
        }else {
            
            NSLog(@"No Screen Name, Set screen name first");
        }
    }
    //NSLog(@"Busy");
    return nil;
}


-(BOOL)hasAPreviousTweet
{
    if((![[TwitterManager sharedObject] hasPreviousTweets]) && tweetIndex == 0) {
        
        return false;
    }
    return true;
}


-(BOOL)hasANextTweet
{
    if((![[TwitterManager sharedObject] hasMoreTweets]) && tweetIndex == ([tweetArray count] - 1)) {
        
        return false;
    }
    return true;
}


-(void)resetScreenName
{
    screenName = nil;
}


-(void)recieveTwitterArrayComplete:(NSArray *)twitterArray
{
    _isReady = false;
    
    if(newScreenName) {
        
        tweetIndex = -1;
        tweetArray = [twitterArray mutableCopy];
        _isReady = true;
        [delegate loadingTweetsComplete];
        
    }else {
        
        if (nextTweetsLoaded) {
            tweetArray = [[tweetArray arrayByAddingObjectsFromArray:twitterArray] mutableCopy];
            timelineIndex++;
            
        }else {
            tweetArray = [[twitterArray arrayByAddingObjectsFromArray:tweetArray] mutableCopy];
            timelineIndex--;
        }
        
        if([tweetArray count] == 60) {
            
            if (nextTweetsLoaded) {
                [tweetArray removeObjectsInRange:NSMakeRange(0, 20)];
                tweetIndex -= 20;
            }else {
                [tweetArray removeObjectsInRange:NSMakeRange(39, 20)];
                tweetIndex += 20;
            }
        }
    }
    
    newScreenName = false;
    _isReady = true;
}


-(void)connectingToTwitterFailed:(NSError *)error
{
    screenName = nil;
    [delegate loadingTweetsFailed:error];
    
    _isReady = true;
}


@end
