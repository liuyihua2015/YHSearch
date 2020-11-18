//
//  YHSearchNavigationBarView.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YHSearchNavigationBarView;
@protocol PPSearchNavigaitonBarViewDelegate <NSObject>

/**
 点击取消按钮
 */
-(void)onClickCancelButtonForSearchNavigaitonBarView:(PPSearchNavigaitonBarView*)searchNavigaitonBarView;

/**
 开始搜索
 */
-(void)searchNavigaitonBarView:(PPSearchNavigaitonBarView*)searchNavigaitonBarView beginSearchWithSearchText:(NSString*)searchText;

@end

/**
 搜索导航栏
 */
@interface YHSearchNavigationBarView : UIView

@property(nonatomic,weak)id<PPSearchNavigaitonBarViewDelegate>delegate;
@property (nonatomic, assign) BOOL isChild;
/**
 searchTextField成为第一响应者
 */
-(void)searchbBecomeFirstResponder;

@end

NS_ASSUME_NONNULL_END
