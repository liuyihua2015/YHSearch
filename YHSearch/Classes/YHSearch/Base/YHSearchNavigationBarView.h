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
-(void)onClickCancelButtonForSearchNavigaitonBarView:(YHSearchNavigationBarView*)searchNavigaitonBarView;

@optional

/// TextField开始编辑
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldBeginEditing:(UITextField *)textField;

/// TextField监听键盘的输入
/// @param textField textField
-(void)searchNavigaitonBarViewByTextFieldDidChange:(UITextField *)textField;

/// 开始搜索
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldReturn:(UITextField *)textField;

/// TextField 清空
/// @param textField textField
-(BOOL)searchNavigaitonBarViewByTextFieldShouldClear:(UITextField *)textField;


@end

/**
 搜索导航栏
 */
@interface YHSearchNavigationBarView : UIView

@property(nonatomic,weak)id<PPSearchNavigaitonBarViewDelegate>delegate;

/**
 searchTextField成为第一响应者
 */
-(void)searchBecomeFirstResponder;
/**
 searchTextField失去第一响应者
 */
-(void)searchResignFirstResponder;

@property(nonatomic,strong)UIView * searchView;
@property(nonatomic,strong)UIImageView * searchIconImageView;
@property(nonatomic,strong)UITextField * searchTextField;
@property(nonatomic,strong)UIButton * cancelButton;

@end

NS_ASSUME_NONNULL_END
