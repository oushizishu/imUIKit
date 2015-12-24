//
//  BaseCellMode.h
//  
//  说明:cellMode的基础类
//  Created by wangziliang on 15/10/8.
//

#import <Foundation/Foundation.h>
#import "CustomTableView.h"

@interface BaseModeCell : UITableViewCell

@property(weak ,nonatomic)BaseCellMode *cellMode;

-(void)setMyCellMode:(BaseCellMode*)cellMode;

@end

@interface BaseCellMode()

@property(weak ,nonatomic)BaseModeCell *modeCell;

-(NSString*)getCellIdentifier;

-(CGFloat)getCellHeight;

-(BaseModeCell*)createModeCell;

-(void)setMyModeCell:(BaseModeCell*)cell;

//

@end
