//
//  YHSearchTagConfigure.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/19.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//  搜索标签tag配置

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 style of popular search
 */
typedef NS_ENUM(NSInteger, EmptyBtnStyle)  {
    EmptyBtnStyleImage,
    EmptyBtnStyleTitle,
    EmptyBtnStyleTitleImage,
    EmptyBtnStyleDefault = EmptyBtnStyleImage // default is `EmptyBtnStyleImage`
};

@interface YHSearchTagConfigure : NSObject
/// Tagleft间距,默认8
@property (nonatomic, assign) int tagLeftMargin;
/// Tag文本左右内边距值,默认20
@property (nonatomic, assign) int tagLeftPanding;
/// Tag视图高度
@property (nonatomic, assign) int tagHeight;
/// Tag文本显示长度控制， 默认不作控制
@property (nonatomic, assign) int historytTagTextDisplayLength;
/// Tag文本边框，默认无
@property (nonatomic, strong) UIColor *tagBorderColor;
/// Tag文本边框宽度，默认0
@property (nonatomic, assign) CGFloat tagBorderWidth;
/// Tag文本圆角，默认5
@property (nonatomic, assign) CGFloat tagCornerRadius;
/// Tag文本，默认 系统字体 12
@property (nonatomic, strong) UIFont *tagFont;
/// Tag文本字体颜色，默认 #999999
@property (nonatomic, strong) UIColor *tagTitleColor;
/// Tag文本背景颜色，默认 #F9F9F9
@property (nonatomic, strong) UIColor *tagBackgroundColor;
///searchTextField Close 图片更换, 默认不做修改
@property (nonatomic, strong) UIImage * textFieldCloseImage;
/// searchIconImageView 图片更换, 默认不做修改
@property (nonatomic, strong) UIImage * searchIconImage;

/// emptyBtnStyle 历史记录删除按钮样式 default is `EmptyBtnStyleImage`
@property (nonatomic, assign) EmptyBtnStyle emptyBtnStyle;
/// searchHistoryDeleteImage 历史记录删除按钮图片更换, 默认不做修改empty
@property (nonatomic, strong) UIImage * searchHistoryDeleteImage;
/// searchHistoryDeleteTitle 历史记录删除按钮文本更换, 默认清空
@property (nonatomic, copy ) NSString * searchHistoryDeleteTitle;
/// searchHistoryDeleteImage 历史记录单条删除按钮图片更换, 默认不做修改empty
@property (nonatomic, strong) UIImage * searchHistoryItemDeleteImage;
/// searchHistoryDeleteImage 历史记录单条删除按钮图片不显示,默认NO,cell样式有效
@property (nonatomic, assign) BOOL searchHistoryItemDeleteImageNotShow;
/// searchHistoryMaxRows  历史搜索最大显示行数，默认不做控制
@property (nonatomic, assign) int searchHistoryMaxRows;
/// searchHotMaxRows  热门搜索最大显示行数，默认不做控制
@property (nonatomic, assign) int searchHotMaxRows;



@end

NS_ASSUME_NONNULL_END
