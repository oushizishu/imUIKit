//
//  BJChatLoadMoreHeadView.h
//  BJEducation_student
//
//  Created by Mrlu-bjhl on 15/3/12.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    EGOPullNormal = 0,
    EGOPullLoading = 1,
    EGOPullPulling = 2
} EGOPullState;

@protocol BJChatLoadMoreHeadViewDelegate;

@interface BJChatLoadMoreHeadView : UIView {
    EGOPullState _state;
    UIActivityIndicatorView *_activityView;
//    UILabel *_label;
    BOOL _isLoading;
}

@property (weak, nonatomic) id<BJChatLoadMoreHeadViewDelegate> delegate;
@property (assign, nonatomic) BOOL canLoadMore;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)bjChatLoadMoreHeadViewScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
@end

@protocol BJChatLoadMoreHeadViewDelegate<NSObject>

- (void)bjChatLoadMoreHeadViewDidTriggerRefresh:(BJChatLoadMoreHeadView *)view;

@end
