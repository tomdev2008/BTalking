//
//  BTMeetingCreateViewController.h
//  SayAbout
//
//  Created by admin on 14-7-22.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTFriendFindViewController.h"

@interface BTMeetingCreateViewController : UIViewController<PassMeetingValueDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tv_title;

@property (strong, nonatomic) IBOutlet UITextView *tv_admin;

@property (strong, nonatomic) IBOutlet UITextView *tv_begintime;

@property (strong, nonatomic) IBOutlet UITextView *tv_endtime;

@property (strong, nonatomic) IBOutlet UITextView *tv_people;

@property (strong, nonatomic) IBOutlet UIButton *btn_admin;

@property (strong, nonatomic) IBOutlet UIButton *btn_begintime;

@property (strong, nonatomic) IBOutlet UIButton *btn_endtime;

@property (strong, nonatomic) IBOutlet UIButton *btn_save;

@property (strong, nonatomic) IBOutlet UIButton *btn_people;

@property (nonatomic, assign) BTRequestId mRequestId;

- (IBAction)select_admin:(id)sender;

- (IBAction)select_begintime:(id)sender;

- (IBAction)select_endtime:(id)sender;

- (IBAction)select_people:(id)sender;

- (IBAction)save_meeting:(id)sender;

@end
