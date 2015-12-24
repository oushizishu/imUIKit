//
//  CustomTableViewController.h
//  
//  说明:定制的tableview视图
//  Created by wangziliang on 15/11/12.
//

#import <UIKit/UIKit.h>
#import "CustomTableView.h"

@interface CustomTableViewController()

//内容数组
@property(strong ,nonatomic)NSMutableArray *sectionArray;
@property(strong ,nonatomic)UITableView *tableView;

@end
