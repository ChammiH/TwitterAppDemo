//
//  TwitterObject.m
//  TwitterAppDemo
//
//  Created by Chandima Herath on 3/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import "TwitterManager.h"
#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

static TwitterManager *twitterManager;

@interface TwitterManager()<NSURLConnectionDataDelegate> {
    
    BOOL newScreenName;
    NSInteger maxIndex;
    NSInteger timelineIndex;
    
    NSString *oauthConsumerKey;
    NSString *oauthConsumerSecret;
    NSString *oauthToken;
    NSString *oauthTokenSecret;
    
    NSString *maxID;
    NSString *screenName;
    NSArray *tweetArray;
    NSMutableArray *maxIDArray;
    NSMutableData *dataRecieved;
    id <TwitterManagerProtocol> delegate;
}

@end


/*
 
 This class will download 20 tweets at a time using the twitter's REST API.
 
 You can use methods loadNextTweets and loadPreviousTweets to go through a users timeline 20 tweets at a time.
 
 At the moment there's no login needed, as this app only retrives tweets. And oAuth login information are used from a account I created for this purpose only
 
*/


@implementation TwitterManager

//This creates a singleton object
+(TwitterManager *) sharedObject
{
    if(twitterManager == nil) {
        
        twitterManager = [[TwitterManager alloc] init];
    }
    return twitterManager;
}


-(id)init
{
    if (self = [super init]) {
        
        maxID = @"";
        maxIndex = 0;
        timelineIndex = 0;
        newScreenName = false;
        tweetArray = [[NSArray alloc] init];
        maxIDArray = [[NSMutableArray alloc] init];
        
        oauthConsumerKey = @"8M9GNqhXrfyjsW1naVDfLrfYy";
        oauthConsumerSecret = @"b9671nlWmlxGPw3Uu1K9HQcmkMKUADJKauNUj018qbkTDPja6j";
        oauthToken = @"3269664392-GWu8XkiHHh2GyURYyWFSB6wevfMYMVBMcqIcRQv";
        oauthTokenSecret = @"FXQZC4R9O0v2QrDK7P1JKIR9G3H6EZ8QZkKxo4OABqOc5";
    }
    return self;
}


//Call this method before calling, loadNextTweets and loadPreviousTweets
-(void) getUserTimeLine:(NSString *)screenNameArg delegate:(id <TwitterManagerProtocol>) delegateArg
{
    
    if(screenName == screenNameArg) {
        newScreenName = false;
    }else {
        newScreenName = true;
    }
    
    delegate = delegateArg;
    screenName = screenNameArg;
    dataRecieved = [[NSMutableData alloc] init];
    
    
    //Nonce
    NSString *nonce = @"";
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (int i = 0; i < 32; i++) {
        nonce = [NSString stringWithFormat:@"%@%c", nonce, [letters characterAtIndex:arc4random() % 52]];
    }
    
    
    //Request URL
    NSString *baseURLString = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?%@screen_name=%@", maxID, screenName];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //TimeStamp
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    float timeStamp = ti;
    
    
    //oAuthSignature
    NSString *parameterString = [NSString stringWithFormat:@"%@oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=HMAC-SHA1&oauth_timestamp=%i&oauth_token=%@&oauth_version=1.0&screen_name=%@", maxID, oauthConsumerKey, nonce, (int)timeStamp, oauthToken, screenName];
    NSString *baseString = [NSString stringWithFormat:@"%@%@%@%@", @"GET&", [self URLEncodedString_ch:baseURLString], @"&", [self URLEncodedString_ch:parameterString]];
    NSString *signingKey = [NSString stringWithFormat:@"%@&%@", oauthConsumerSecret, oauthTokenSecret];
    NSString *oauthSignature = [self hmacsha1:baseString secret:signingKey];
    oauthSignature = [self URLEncodedString_ch:oauthSignature];
    
    
    //Final Authorization String
    NSString *authString = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\",oauth_token=\"%@\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"%i\",oauth_nonce=\"%@\",oauth_version=\"1.0\",oauth_signature=\"", oauthConsumerKey, oauthToken, (int)timeStamp, nonce];
    authString = [NSString stringWithFormat:@"%@%@%@", authString, oauthSignature, @"\""];
    
    
    //New Request
    NSURL *newURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:newURL];
    [newRequest setHTTPMethod:@"GET"];
    [newRequest addValue:authString forHTTPHeaderField:@"Authorization"];
    [newRequest addValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    //Send request
    NSURLConnection *connection;
    connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dataRecieved appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:dataRecieved options:NSJSONReadingAllowFragments error:nil];
    
    NSString *finalString;
    BOOL accountExists = false;
    BOOL tweetsExists = false;
    
    //Chaeck if the account exists and has any tweets
    if([jsonObject isKindOfClass:[NSArray class]]) {
        
        tweetArray = jsonObject;
        accountExists = true;
        
        if ([tweetArray count] > 0) {
            tweetsExists = true;
        }
    }
    
    //If the account exists and has tweets notify the delegate the tweets downloaded successfully
    if(accountExists && tweetsExists) {
        
        tweetArray = jsonObject;
        finalString = [NSString stringWithFormat:@" Found %i    Tweets    \n\n\n", (int)[tweetArray count]];
        
        for (NSDictionary *tweet in tweetArray) {
            finalString = [NSString stringWithFormat:@"%@%@\n----------------\n\n", finalString, [tweet valueForKey:@"text"]];
        }
        
        
        if(newScreenName) {
            
            NSDictionary *tweet = tweetArray[0];
            [maxIDArray removeAllObjects];
            timelineIndex = 0;
            maxIndex = 0;
            
            if(tweet != nil) {
                
                NSString *firstID = [NSString stringWithFormat:@"max_id=%@&", [tweet valueForKey:@"id_str"]];
                [maxIDArray addObject:firstID];
            }
        }
        
        
        [delegate recieveTwitterArrayComplete:tweetArray];
        
        if ([delegate respondsToSelector:@selector(recieveTwitterStringComplete:)]) {
            [delegate recieveTwitterStringComplete:finalString];
        }
        
    }else {
        
        //If Account does not exists or no tweets in account, notify the delegate that it cannot proceed further
        
        tweetArray = [[NSArray alloc] init];
        [maxIDArray removeAllObjects];
        
        if (!accountExists) {
            
            NSError *error = [NSError errorWithDomain:@"TwitterManager" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Account does not exists" forKey:@"error_info"]];
            [delegate connectingToTwitterFailed:error];
            
            
        }else {
            if (!tweetsExists) {
                
                NSError *error = [NSError errorWithDomain:@"TwitterManager" code:2 userInfo:[NSDictionary dictionaryWithObject:@"No tweets from this user" forKey:@"error_info"]];
                [delegate connectingToTwitterFailed:error];
                
            }
        }
    }
    
    [dataRecieved setLength:0];
}


//Connection failed, notify the delegate that it cannot proceed further
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSError *newError = [NSError errorWithDomain:@"TwitterManager" code:3 userInfo:[NSDictionary dictionaryWithObject:@"Something went wrong" forKey:@"error_info"]];
    
    if ([delegate respondsToSelector:@selector(connectingToTwitterFailed:)]) {
        [delegate connectingToTwitterFailed:newError];
    }
}


//This SHA method I downloaded from stack overflow
- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
    
    return hash;
}


//This Percent encoding method I downloaded from stack overflow
- (NSString *) URLEncodedString_ch:(NSString *)sourceString {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[sourceString UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
