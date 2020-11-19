//
//  UIColor+YHSearchExtension.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (YHSearchExtension)
/**
 Returns the corresponding color according to the hexadecimal string.

 @param hexString   hexadecimal string(eg:@"#ccff88")
 @return new instance of `UIColor` class
 */
+ (instancetype)yh_colorWithHexString:(NSString *)hexString;

/**
  Returns the corresponding color according to the hexadecimal string and alpha.

 @param hexString   hexadecimal string(eg:@"#ccff88")
 @param alpha       alpha
 @return new instance of `UIColor` class
 */
+ (instancetype)yh_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
