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

#define PYSEARCH_MARGIN 10
#define PYSEARCH_BACKGROUND_COLOR PYSEARCH_COLOR(255, 255, 255)

#ifdef DEBUG
#define PYSEARCH_LOG(...) NSLog(__VA_ARGS__)
#else
#define PYSEARCH_LOG(...)
#endif

#define PYSEARCH_COLOR(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define PYSEARCH_RANDOM_COLOR  PYSEARCH_COLOR(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

#define PYSEARCH_DEPRECATED(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#define PYSEARCH_REALY_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define PYSEARCH_REALY_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define PYScreenW (PYSEARCH_REALY_SCREEN_WIDTH < PYSEARCH_REALY_SCREEN_HEIGHT ? PYSEARCH_REALY_SCREEN_WIDTH : PYSEARCH_REALY_SCREEN_HEIGHT)
#define PYScreenH (PYSEARCH_REALY_SCREEN_WIDTH > PYSEARCH_REALY_SCREEN_HEIGHT ? PYSEARCH_REALY_SCREEN_WIDTH : PYSEARCH_REALY_SCREEN_HEIGHT)
#define PYSEARCH_SCREEN_SIZE CGSizeMake(PYScreenW, PYScreenH)

//历史记录
#define PYSEARCH_SEARCH_HISTORY_CACHE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YHSearchhistories.plist"] // the path of search record cached

UIKIT_EXTERN NSString *const YHSearchSearchPlaceholderText;
UIKIT_EXTERN NSString *const YHSearchHotSearchText;
UIKIT_EXTERN NSString *const YHSearchSearchHistoryText;
UIKIT_EXTERN NSString *const YHSearchEmptySearchHistoryText;
UIKIT_EXTERN NSString *const YHSearchEmptyButtonText;
UIKIT_EXTERN NSString *const YHSearchEmptySearchHistoryLogText;
UIKIT_EXTERN NSString *const YHSearchCancelButtonText;
UIKIT_EXTERN NSString *const YHSearchBackButtonText;
