//
//  UIView+YHSearchExtension.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "UIView+YHSearchExtension.h"

@implementation UIView (YHSearchExtension)

- (void)setYh_x:(CGFloat)yh_x
{
    CGRect frame = self.frame;
    frame.origin.x = yh_x;
    self.frame = frame;
}

- (CGFloat)yh_x
{
    return self.yh_origin.x;
}

- (void)setYh_centerX:(CGFloat)yh_centerX
{
    CGPoint center = self.center;
    center.x = yh_centerX;
    self.center = center;
}

- (CGFloat)yh_centerX
{
    return self.center.x;
}

-(void)setYh_centerY:(CGFloat)yh_centerY
{
    CGPoint center = self.center;
    center.y = yh_centerY;
    self.center = center;
}

- (CGFloat)yh_centerY
{
    return self.center.y;
}

- (void)setYh_y:(CGFloat)yh_y
{
    CGRect frame = self.frame;
    frame.origin.y = yh_y;
    self.frame = frame;
}

- (CGFloat)yh_y
{
    return self.frame.origin.y;
}

- (void)setYh_size:(CGSize)yh_size
{
    CGRect frame = self.frame;
    frame.size = yh_size;
    self.frame = frame;

}

- (CGSize)yh_size
{
    return self.frame.size;
}

- (void)setYh_height:(CGFloat)yh_height
{
    CGRect frame = self.frame;
    frame.size.height = yh_height;
    self.frame = frame;
}

- (CGFloat)yh_height
{
    return self.frame.size.height;
}

- (void)setYh_width:(CGFloat)yh_width
{
    CGRect frame = self.frame;
    frame.size.width = yh_width;
    self.frame = frame;

}

-(CGFloat)yh_width
{
    return self.frame.size.width;
}

- (void)setYh_origin:(CGPoint)yh_origin
{
    CGRect frame = self.frame;
    frame.origin = yh_origin;
    self.frame = frame;
}

- (CGPoint)yh_origin
{
    return self.frame.origin;
}
@end
