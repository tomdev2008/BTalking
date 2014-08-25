//
//  LoginViewController.h
//  SayAbout
//
//  Created by admin on 14-7-9.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *tv_loginname;

@property (weak, nonatomic) IBOutlet UITextField *tv_password;
@property (weak, nonatomic) IBOutlet UITextField *tv_server;


- (IBAction)login:(id)sender;


@end
