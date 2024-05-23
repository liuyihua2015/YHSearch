//
//  YHSearchConst.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "UIView+YHSearchExtension.h"
#import "UIColor+YHSearchExtension.h"
#import "NSBundle+YHSearchExtension.h"
#import "YHSearchTagConfigure.h"

#define YHSEARCH_MARGIN 16
#define YHSEARCH_BACKGROUND_COLOR YHSEARCH_COLOR(255, 255, 255)

#ifdef DEBUG
#define YHSEARCH_LOG(...) NSLog(__VA_ARGS__)
#else
#define YHSEARCH_LOG(...)
#endif

#define YHSEARCH_COLOR(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define YHSEARCH_RANDOM_COLOR  YHSEARCH_COLOR(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

#define YHSEARCH_DEPRECATED(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define YHSEARCH_REALY_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define YHSEARCH_REALY_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define YHScreenW (YHSEARCH_REALY_SCREEN_WIDTH < YHSEARCH_REALY_SCREEN_HEIGHT ? YHSEARCH_REALY_SCREEN_WIDTH : YHSEARCH_REALY_SCREEN_HEIGHT)
#define YHScreenH (YHSEARCH_REALY_SCREEN_WIDTH > YHSEARCH_REALY_SCREEN_HEIGHT ? YHSEARCH_REALY_SCREEN_WIDTH : YHSEARCH_REALY_SCREEN_HEIGHT)
#define YHSEARCH_SCREEN_SIZE CGSizeMake(YHScreenW, YHScreenH)

//屏幕尺寸
/**
 导航栏高度
 */
#define YH_NavgationBarHeight 44
/**
 状态栏高度
 */
#define YH_StatusBarHeight  [UIApplication sharedApplication].statusBarFrame.size.height
/**
 导航栏高度+状态栏高度
 */
#define YH_NavgationFullHeight YH_NavgationBarHeight + YH_StatusBarHeight


//历史记录
#define YHSEARCH_SEARCH_HISTORY_CACHE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YHSearchhistories.plist"] // the path of search record cached

UIKIT_EXTERN NSString *const YHSearchSearchPlaceholderText;
UIKIT_EXTERN NSString *const YHSearchHotSearchText;
UIKIT_EXTERN NSString *const YHSearchSearchHistoryText;
UIKIT_EXTERN NSString *const YHSearchEmptySearchHistoryText;
UIKIT_EXTERN NSString *const YHSearchEmptyButtonText;
UIKIT_EXTERN NSString *const YHSearchEmptySearchHistoryLogText;
UIKIT_EXTERN NSString *const YHSearchCancelButtonText;
UIKIT_EXTERN NSString *const YHSearchBackButtonText;
