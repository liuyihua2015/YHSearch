//
//  NSBundle+YHSearchExtension.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (YHSearchExtension)
/**
 Get the localized string

 @param key     key for localized string
 @return a localized string
 */
+ (NSString *)yh_localizedStringForKey:(NSString *)key;

/**
 Get the path of `YHSearch.bundle`.

 @return path of the `YHSearch.bundle`
 */
+ (NSBundle *)yh_searchBundle;

/**
 Get the image in the `YHSearch.bundle` path

 @param name name of image
 @return a image
 */
+ (UIImage *)yh_imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
