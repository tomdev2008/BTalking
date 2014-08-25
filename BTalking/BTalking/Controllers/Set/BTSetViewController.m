//
//  BTSetViewController.m
//  SayAbout
//
//  Created by admin on 14-8-20.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import "AppDelegate.h"
#import "BTSetViewController.h"
#import "LoginViewController.h"

@interface BTSetViewController ()

@end

@implementation BTSetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"_userid"];
    [defaults setObject:@"" forKey:@"_loginname"];
    [defaults setObject:@"" forKey:@"_username"];
    [defaults setObject:@"" forKey:@"_password"];
    [defaults setObject:@"" forKey:@"_ptoken"];
    [defaults setObject:@"" forKey:@"_server"];
    
    AppDelegate *delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
   
    delegate.window.rootViewController = loginViewController;
}
@end
