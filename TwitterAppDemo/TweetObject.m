//
//  TweetObject.m
//  TwitterAppDemo
//
//  Created by Chandima Herath on 4/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import "TweetObject.h"

static UIImage *profileImage;
static NSString *screenName;

@interface TweetObject()<NSURLConnectionDataDelegate> {
    
    CGFloat screenWidth;
    CGFloat screenHeight;
    UILabel *loadingLabel;
    NSMutableData *dataRecieved;
}

@end

@implementation TweetObject

/*
 
 Tweet object is a subclass of UIView.
 
 Given a dictionary this class will make a tweets view that can be shown to the user.
 
*/


+(TweetObject *) initWithDictinary:(NSDictionary *) tweetInfo Offset:(TweetOffset)offset
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSInteger offsetDistance = 0;
    
    if(offset == TweetOffsetLeft) {
        offsetDistance -= screenWidth;
    }
    
    if(offset == TweetOffsetRight) {
        offsetDistance += screenWidth;
    }
    
    TweetObject *tweet = [[TweetObject alloc]initWithFrame:CGRectMake(10 + offsetDistance, 10, screenWidth - 20, screenHeight - 20)];
    [tweet buildTweetWithDictionaryInformation:tweetInfo];
    
    return tweet;
}


-(void) buildTweetWithDictionaryInformation:(NSDictionary *) tweetInfo
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    dataRecieved = [[NSMutableData alloc] init];
    
    NSDictionary *userInfo = [tweetInfo valueForKey:@"user"];
    
    [self setBackgroundColor:[UIColor blueColor]];
    
    UILabel *_displayLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, screenWidth - 40, screenHeight - 40)];
    [_displayLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_displayLabel setNumberOfLines:0];
    [_displayLabel setTextAlignment:NSTextAlignmentCenter];
    [_displayLabel setBackgroundColor:[UIColor yellowColor]];
    
    [_displayLabel setText:@"\n\n\n Slide right for next Tweet...! \n\n\n Slide down for menu...!"];
    [self addSubview:_displayLabel];
    
    if(tweetInfo != nil) {
        
        NSString *profileImageURL = [userInfo valueForKey:@"profile_image_url_https"];
        profileImageURL = [profileImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        
        if(![screenName isEqualToString:[userInfo valueForKey:@"screen_name"]]) {
            screenName = [userInfo valueForKey:@"screen_name"];
            profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImageURL]]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:profileImage];
            [imageView setFrame:CGRectMake((screenWidth / 2.0) - 83, (screenHeight / 5.0), 146, 146)];
            [self addSubview:imageView];
            
            
        }else {
            
            [_displayLabel setText:[tweetInfo valueForKey:@"text"]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:profileImage];
            [imageView setFrame:CGRectMake((screenWidth / 2.0) - 46.5, (screenHeight / 5.0), 73, 73)];
            [self addSubview:imageView];
            
            NSDictionary *extendedEntities = [tweetInfo valueForKey:@"extended_entities"];
            
            if (extendedEntities != nil) {
                
                NSArray *mediaArray = [extendedEntities valueForKey:@"media"];
                
                NSDictionary *mediaInfo = mediaArray[0];
                
                NSString *mediaImageURL = [mediaInfo valueForKey:@"media_url_https"];
                
                NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:mediaImageURL]];
                
                NSURLConnection *connection;
                connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
                
                loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth / 2.0) - 70, ((screenHeight * 3) / 5.0), 200, 20)];
                [loadingLabel setText:@"Loading image..."];
                [self addSubview:loadingLabel];
                
            }
        }
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dataRecieved appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [loadingLabel removeFromSuperview];
    UIImage *image = [UIImage imageWithData:dataRecieved];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(20, ((screenHeight * 3) / 5.0), screenWidth - 60, (screenHeight / 3.0))];
    [self addSubview:imageView];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [loadingLabel setText:@"Loading failed"];
}


-(CGRect) getOffsetLeftPosition
{
    return CGRectMake(10 - screenWidth, 10, screenWidth - 20, screenHeight - 20);
}


-(CGRect) getOffsetCenterPosition
{
    return CGRectMake(10, 10, screenWidth - 20, screenHeight - 20);
}


-(CGRect) getOffsetRightPosition
{
    return CGRectMake(10 + screenWidth, 10, screenWidth - 20, screenHeight - 20);
}


+(NSString *) getScreenName
{
    return screenName;
}


+(void) resetScreenName
{
    screenName = nil;
}

@end
