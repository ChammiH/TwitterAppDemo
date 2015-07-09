//
//  TwitterManager.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 2/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterManagerProtocol <NSObject>

@required
-(void)recieveTwitterArrayComplete:(NSArray *)twitterArray;
@optional
-(void)recieveTwitterStringComplete:(NSString *)twitterString;
-(void)connectingToTwitterFailed:(NSError *)error;

@end


@interface TwitterManager : NSObject

+(TwitterManager *) sharedObject;
-(void) getUserTimeLine:(NSString *)screenNameArg delegate:(id <TwitterManagerProtocol>) delegateArg;

@end
