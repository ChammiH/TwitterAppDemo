//
//  TweetObject.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 4/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TweetOffset) {
    TweetOffsetLeft,
    TweetOffsetCenter,
    TweetOffsetRight
};

@interface TweetObject : UIView

+(TweetObject *) initWithDictinary:(NSDictionary *) tweetInfo Offset:(TweetOffset)offset;
+(void) resetScreenName;
+(NSString *) getScreenName;
-(CGRect) getOffsetLeftPosition;
-(CGRect) getOffsetCenterPosition;
-(CGRect) getOffsetRightPosition;

@end
