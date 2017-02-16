
//
//  CustomTableView.h
//
//  说明:封装的CustomTableView模块的头文件。外部使用者，只使用在其中定义的部分。不该暴露的属性与方法，不要暴露给外部，以防止造成使用混淆。
//  Created by wangziliang on 15/10/8.
//

#import <Foundation/Foundation.h>

@class CustomTableViewController;

typedef NS_ENUM(NSInteger, ArrayInsertPosition)
{
    ArrayInsertPosition_Before = 1,
    ArrayInsertPosition_After = 2
};

@class SectionMode;

@interface BaseCellMode : NSObject

@property(weak ,nonatomic)SectionMode *sectionMode;

@end


@interface SectionMode : NSObject

@property(weak,nonatomic)CustomTableViewController *customTableViewController;
//section header高度
@property(nonatomic)CGFloat headerHeight;
//section header视图
@property(strong ,nonatomic)UIView *headerView;
//section footer高度
@property(nonatomic)CGFloat footerHeight;
//section footer视图
@property(strong ,nonatomic)UIView *footerView;

//设置显示cellmode数组
-(void)setRows:(NSArray<BaseCellMode *> *)array;
//插入显示cellMode数组
-(void)insertRows:(NSArray<BaseCellMode *> *)array withInsertCellMode:(BaseCellMode*)mode withInsertType:(ArrayInsertPosition)positon;
//添加显示cellMode数组
-(void)addRows:(NSArray<BaseCellMode *> *)array;
//移除显示cellMode数组
-(void)removeRows:(NSArray<BaseCellMode *> *)array;

@end


@protocol CustomTableViewControllerDelegate <NSObject>

//用户点击cell
-(void)userHitCellMode:(BaseCellMode*)cellMode;
//用户滚动到底部
-(void)userScrollBottom;

-(void)tableViewDidScroll:(UIScrollView *)scrollView;

@end

@interface CustomTableViewController : UIViewController

@property(weak ,nonatomic)id<CustomTableViewControllerDelegate> delegate;
//header视图
@property(strong ,nonatomic)UIView *tableHeaderView;
//footer视图
@property(strong ,nonatomic)UIView *tableFooterView;
//索引数组
@property (nonatomic,strong) NSArray<NSString *> *sectionTitles;
//索引偏移
@property (nonatomic) int Offset;

//初始化
-(instancetype)initWithFrame:(CGRect)frame;

//设定显示section数组
-(void)setSections:(NSArray<SectionMode *> *)array;
//插入显示section数组
-(void)insertSections:(NSArray<SectionMode *> *)array withInsertSection:(SectionMode*)mode withInsertType:(ArrayInsertPosition)positon;
//添加显示section数组
-(void)addSections:(NSArray<SectionMode *> *)array;
//移除显示section数组
-(void)removeSections:(NSArray<SectionMode *> *)array;

-(CGPoint)getCurOffSetPoint;
-(void)setCurOffSetPoint:(CGPoint)point;

@end


