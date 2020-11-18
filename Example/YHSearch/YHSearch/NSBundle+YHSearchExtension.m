//
//  NSBundle+YHSearchExtension.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "NSBundle+YHSearchExtension.h"
#import "YHSearchViewController.h"

@implementation NSBundle (YHSearchExtension)

+ (NSBundle *)yh_searchBundle
{
    static NSBundle *searchBundle = nil;
    if (nil == searchBundle) {
        //Default use `[NSBundle mainBundle]`.
        searchBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"PYSearch" ofType:@"bundle"]];
        /**
         If you use pod import and configure `use_frameworks` in Podfile, [NSBundle mainBundle] does not load the `PYSearch.fundle` resource file in `PYSearch.framework`.
         */
        if (nil == searchBundle) { // Empty description resource file in `PYSearch.framework`.
            searchBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[YHSearchViewController class]] pathForResource:@"YHSearch" ofType:@"bundle"]];
        }
    }
    return searchBundle;
}

+ (NSString *)yh_localizedStringForKey:(NSString *)key;
{
    return [self yh_localizedStringForKey:key value:nil];
}

+ (NSString *)yh_localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (nil == bundle) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) language = @"en";
        else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans";
            }
        } else {
            language = @"en";
        }
        
        // Find resources from `YHSearch.bundle`
        bundle = [NSBundle bundleWithPath:[[NSBundle yh_searchBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}
    
+ (UIImage *)yh_imageNamed:(NSString *)name
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    name = 3.0 == scale ? [NSString stringWithFormat:@"%@@3x.png", name] : [NSString stringWithFormat:@"%@@2x.png", name];
    UIImage *image = [UIImage imageWithContentsOfFile:[[[NSBundle yh_searchBundle] resourcePath] stringByAppendingPathComponent:name]];
    return image;
}
@end
