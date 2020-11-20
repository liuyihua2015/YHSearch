//
//  YHSearchTagConfigure.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/19.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//  搜索标签tag配置

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YHSearchTagConfigure : NSObject
/// Tag文本显示长度控制， 默认不作控制
@property (nonatomic, assign) int tagTextDisplayLength;
/// Tag 热门搜索显示图标长度控制（前几个显示）， 默认不作控制
@property (nonatomic, assign) int tagHotImageDisplayLength;
/// Tag 热门搜索图标图片， 默认 图"hot.png"
@property (nonatomic, strong) UIImage *tagHotImage;
/// Tag文本边框，默认无
@property (nonatomic, strong) UIColor *tagBorderColor;
/// Tag文本边框宽度，默认0
@property (nonatomic, assign) CGFloat tagBorderWidth;
/// Tag文本圆角，默认5
@property (nonatomic, assign) CGFloat tagCornerRadius;
/// Tag文本边框宽度，默认 系统字体 12
@property (nonatomic, strong) UIFont *tagFont;
/// Tag文本字体颜色，默认 #999999
@property (nonatomic, strong) UIColor *tagTitleColor;
/// Tag文本背景颜色，默认 #F9F9F9
@property (nonatomic, strong) UIColor *tagBackgroundColor;
///searchTextField Close 图片更换, 默认不做修改
@property (nonatomic, strong) UIImage * textFieldCloseImage;


@end

NS_ASSUME_NONNULL_END
