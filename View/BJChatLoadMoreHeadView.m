//
//  BJChatLoadMoreHeadView.m
//  BJEducation_student
//
//  Created by Mrlu-bjhl on 15/3/12.
//  Copyright (c) 2015年 Baijiahulian. All rights reserved.
//

#import "BJChatLoadMoreHeadView.h"

@interface BJChatLoadMoreHeadView ()

- (void)setState:(EGOPullState)aState;

@end

@implementation BJChatLoadMoreHeadView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _canLoadMore = NO;
        
        /* Config activity indicator */
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(0,0, 20.0f, 20.0f);
        view.center = CGPointMake(frame.size.width/2., frame.size.height/2.);
        [view setHidesWhenStopped:YES];
        [self addSubview:view];
        _activityView = view;
        
        
//        UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
//        [signLabel setBackgroundColor:[UIColor clearColor]];
//        [signLabel setTextAlignment:NSTextAlignmentCenter];
//        [signLabel setTextColor:[UIColor lightGrayColor]];
//        [signLabel setText:@"没有更多消息喽"];
//        [signLabel setFont:UIFont_Font(14)];
//        [signLabel setCenter:CGPointMake(frame.size.width/2., frame.size.height/2.)];
//        [self addSubview:signLabel];
//        _label = signLabel;
        
        [self setState:EGOPullNormal];
    }
    
    return self;
    
}


#pragma mark -
#pragma mark Setters
- (void)setState:(EGOPullState)aState{
    
    switch (aState) {
        case EGOPullNormal:{
            [_activityView stopAnimating];
            [self setHidden:YES];
        }
            break;
        case EGOPullLoading:{
            [_activityView startAnimating];
            [self setHidden:NO];
        }
            break;
        case EGOPullPulling:{
            [_activityView startAnimating];
            [self setHidden:NO];
        }
            break;
        default:
        {
            [_activityView stopAnimating];
            [self setHidden:YES];
        }
            break;
    }
    
    _state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == EGOPullNormal && _canLoadMore) {
        if (scrollView.contentOffset.y<0) {
            
            [self setState:EGOPullPulling];
            
            CGFloat offset = self.frame.size.height;
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.top = offset;
            scrollView.contentInset = currentInsets;
            
            CGRect frame = self.frame;
            frame.origin.y = -self.frame.size.height;
            self.frame = frame;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_state == EGOPullPulling && !scrollView.tracking) {
        if(_delegate && [_delegate respondsToSelector:@selector(bjChatLoadMoreHeadViewDidTriggerRefresh:)])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setState:EGOPullLoading];
                [_delegate bjChatLoadMoreHeadViewDidTriggerRefresh:self];
            });
        }
    }
}

- (void)bjChatLoadMoreHeadViewScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {

    if (!_canLoadMore) {
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.top = 0;
        scrollView.contentInset = currentInsets;
    } else {
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.top = self.frame.size.height;
        scrollView.contentInset = currentInsets;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程刷新
        [self setState:EGOPullNormal];
    });
}

- (void)setCanLoadMore:(BOOL)canLoadMore
{
    _canLoadMore = canLoadMore;
}

@end
