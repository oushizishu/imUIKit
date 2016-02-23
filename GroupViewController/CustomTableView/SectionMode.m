//
//  BaseSectionMode.m
//  
//
//  Created by wangziliang on 15/11/12.
//

#import "SectionMode.h"
#import "CustomTableViewController.h"
#import "BaseCellMode.h"

@interface SectionMode()

@property(strong ,nonatomic)NSMutableArray *rowsArray;

@end

@implementation SectionMode

-(void)setRows:(NSArray<BaseCellMode *> *)array
{
    for (int i = 0; i < [self.rowsArray count]; i++) {
        BaseCellMode *itemCellMode = [self.rowsArray objectAtIndex:i];
        if ([self.rowsArray containsObject:itemCellMode]) {
            itemCellMode.sectionMode = nil;
        }
    }
    [self.rowsArray removeAllObjects];
    [self.rowsArray addObjectsFromArray:array];
    for (int i = 0; i < [array count]; i++) {
        BaseCellMode *itemCellMode = [array objectAtIndex:i];
        itemCellMode.sectionMode = self;
    }
    if (self.customTableViewController != nil && [self.customTableViewController.sectionArray containsObject:self]) {
        NSInteger sectionIndex = [self.customTableViewController.sectionArray indexOfObject:self];
        NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
        [sets addIndex:sectionIndex];
        [self.customTableViewController.tableView reloadSections:sets withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)insertRows:(NSArray<BaseCellMode *> *)array withInsertCellMode:(BaseCellMode*)mode withInsertType:(ArrayInsertPosition)positon
{
    if ([self.rowsArray containsObject:mode]) {
        NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
        NSInteger rowIndex = [self.rowsArray indexOfObject:mode];
        if (positon == ArrayInsertPosition_After) {
            rowIndex++;
        }
        for (int i = 0; i < [array count]; i++) {
            BaseCellMode *itemCellMode = [array objectAtIndex:i];
            itemCellMode.sectionMode = self;
            [sets addIndex:rowIndex+i];
        }
        [self.rowsArray insertObjects:array atIndexes:sets];
        
        if (self.customTableViewController != nil && [self.customTableViewController.sectionArray containsObject:self]) {
            NSInteger sectionIndex = [self.customTableViewController.sectionArray indexOfObject:self];
            NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
            [sets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [indexPathsArray addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
            }];
            [self.customTableViewController.tableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

-(void)addRows:(NSArray<BaseCellMode *> *)array
{
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    NSInteger rowIndex = [self.rowsArray count];
    for (int i = 0; i < [array count]; i++) {
        BaseCellMode *itemCellMode = [array objectAtIndex:i];
        itemCellMode.sectionMode = self;
        [sets addIndex:rowIndex+i];
    }
    [self.rowsArray insertObjects:array atIndexes:sets];
    
    if (self.customTableViewController != nil && [self.customTableViewController.sectionArray containsObject:self]) {
        NSInteger sectionIndex = [self.customTableViewController.sectionArray indexOfObject:self];
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
        [sets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPathsArray addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
        }];
        [self.customTableViewController.tableView insertRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)removeRows:(NSArray<BaseCellMode *> *)array
{
    NSMutableIndexSet *sets = [[NSMutableIndexSet alloc] init];
    for (int i = 0;  i < [array count]; i++) {
        BaseCellMode *itemMode = [array objectAtIndex:i];
        if ([self.rowsArray containsObject:itemMode]) {
            itemMode.sectionMode = nil;
            [sets addIndex:[self.rowsArray indexOfObject:itemMode]];
        }
    }
    [self.rowsArray removeObjectsAtIndexes:sets];
    
    if (self.customTableViewController != nil && [self.customTableViewController.sectionArray containsObject:self]) {
        NSInteger sectionIndex = [self.customTableViewController.sectionArray indexOfObject:self];
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc] init];
        [sets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPathsArray addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
        }];
        [self.customTableViewController.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(NSArray*)getRows
{
    return _rowsArray;
}

-(NSInteger)getRowsCount
{
    if (_rowsArray != nil) {
        return [_rowsArray count];
    }else
    {
        return 0;
    }
}

-(NSMutableArray*)rowsArray
{
    if (_rowsArray == nil) {
        _rowsArray = [[NSMutableArray alloc] init];
    }
    return _rowsArray;
}

@end
