//
//  IMDefaultCellMode.h
//
//  说明:通用cellMode
//  Created by wangziliang on 15/10/8.
//

#import "BaseCellMode.h"

typedef NS_ENUM(NSInteger, CellArrowType)
{
    CellArrowType_None = 1,
    CellArrowType_ToLeft = 2,
    CellArrowType_ToRigth = 3,
    CellArrowType_ToUp = 4,
    CellArrowType_ToBottom = 5,
};


@interface IMDefaultCell :BaseModeCell

@end

@interface IMDefaultCellMode : BaseCellMode

@property(strong ,nonatomic)UIImage *flagImage;
@property(strong ,nonatomic)NSURL *imageUrl;
@property(strong ,nonatomic)NSString *title;
@property(strong ,nonatomic)NSString *value;
@property(assign ,nonatomic)CellArrowType arrowType;
@property(nonatomic)BOOL ifShowLine;

-(void)setDefaultValue:(NSString *)value;

-(void)setDefaultArrowType:(CellArrowType)type;

@end
