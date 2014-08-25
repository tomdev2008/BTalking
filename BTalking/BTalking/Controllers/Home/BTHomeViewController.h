//
//  BTHomeViewController.h
//  SayAbout
//
//  Created by admin on 14-7-16.
//  Copyright (c) 2014年 RuiBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "OCBorghettiView.h"

@interface BTHomeViewController : UIViewController <OCBorghettiViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,retain) NSMutableDictionary *menuDictionary; // 菜单数据字典

@property(nonatomic,retain) NSMutableArray *dataSource; // 转换后的菜单数据源

@property UITableView *menuTable; //菜单表格

@end
