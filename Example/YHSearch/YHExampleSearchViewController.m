//
//  YHExampleSearchViewController.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/20.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHExampleSearchViewController.h"

@interface YHExampleSearchViewController ()

@end

@implementation YHExampleSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //模拟请求数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray * arrM = [NSMutableArray array];
        for (int i = 0; i<10; i++) {
            if (i % 2 == 0)
            {
                [arrM addObject:[NSString stringWithFormat:@"热门词-%d",i]];
            }else{
                [arrM addObject:[NSString stringWithFormat:@"热门词组火-%d",i]];
            }
        }
        self.hotSearches = arrM;
    });
   
    

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //可以在这里赋值
//    NSMutableArray * arrM = [NSMutableArray array];
//
//    for (int i = 0; i<10; i++) {
//
//        YHSearchHotWordsModel * model = [[YHSearchHotWordsModel alloc]init];
//        model.title = [NSString stringWithFormat:@"热么词%d",i];
//        if (i < 5) {
//            model.isShowHot = YES;
//        }
//        [arrM addObject:model];
//    }
//
//    self.hotSearches = arrM;
    
    
}


@end
