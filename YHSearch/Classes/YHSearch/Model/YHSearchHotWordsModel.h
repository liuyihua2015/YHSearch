//
//  YHSearchHotWordsModel.h
//  PhoenixBookPub
//
//  Created by Yihua Liu on 2020/12/2.
//  Copyright © 2020 PPMG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YHSearchHotWordsModel : NSObject
@property (nonatomic,   copy) NSString *title;
@property (nonatomic, assign) BOOL isShowHot;
@end

NS_ASSUME_NONNULL_END
