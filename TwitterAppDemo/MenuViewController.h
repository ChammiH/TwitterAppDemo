//
//  mainViewController.h
//  TwitterAppDemo
//
//  Created by Chandima Herath on 2/07/15.
//  Copyright (c) 2015 NukaWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

-(IBAction)buttonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadTweetsButton;
@property (weak, nonatomic) IBOutlet UITextField *twHandleTextField;

@end
