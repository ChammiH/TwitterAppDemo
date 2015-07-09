//
//  mainViewController.m
//  TwitterAppDemo
//
//  Created by Chandima Herath on 2/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import "MenuViewController.h"
#import "TwitterViewController.h"


@interface MenuViewController () {
    
    BOOL loading;
    NSTimer *loadingTimer;
    TwitterViewController *twitterViewController;
}
@end


@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    loading = false;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)buttonClicked:(id)sender
{
    
    [_twHandleTextField resignFirstResponder];
    
    if(![_twHandleTextField.text  isEqual: @""]) {
        
        if (loading == false) {
            
            loading = true;
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            twitterViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"twitterViewController"];
            
            twitterViewController.screenName = _twHandleTextField.text;
            [twitterViewController loadTweets];
            
            loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadingTweets) userInfo:nil repeats:YES];
        }
    }
}


-(void)loadingTweets
{
    if (twitterViewController.tvStatus == TVDefault) {
        
        if ([[_loadingLabel text] isEqualToString:@" "]) {
            [_loadingLabel setText:@"Loading..."];
        }else {
            [_loadingLabel setText:@" "];
        }
        
    }else if (twitterViewController.tvStatus == TVLoadedTweets) {
        [loadingTimer invalidate];
        loadingTimer = nil;
        [self presentViewController:twitterViewController animated:YES completion:^{ [_loadingLabel setText:@"Please enter Twitter Username"]; }];
        loading = false;
    }else if (twitterViewController.tvStatus == TVLoadingTweetsFailed) {
        [loadingTimer invalidate];
        loadingTimer = nil;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:twitterViewController.errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [_loadingLabel setText:@"Please enter Twitter Username"];
        loading = false;
    }
}

@end