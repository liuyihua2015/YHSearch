//
//  YHBaseViewController.h
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YHBaseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

/**
 创建tableView

 @param frame 尺寸
 @param style 类型
 */
-(void)setupTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style;

@end

NS_ASSUME_NONNULL_END
