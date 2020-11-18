//
//  YHSearchNavigationBarView.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHSearchNavigationBarView.h"

@interface YHSearchNavigationBarView ()<UITextFieldDelegate>

@property(nonatomic,strong)UIView * searchView;
@property(nonatomic,strong)UIImageView * searchIconImageView;
@property(nonatomic,strong)UITextField * searchTextField;
@property(nonatomic,strong)UIButton * cancelButton;
@property(nonatomic,strong)UIView * line;

@end

@implementation YHSearchNavigationBarView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self p_initData];
        [self p_layoutSubviews];
    }
    return self;
}

-(void)p_initData{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)p_layoutSubviews{
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-50);
        make.height.mas_equalTo(36);
    }];
    [self.searchView setCornerWithDirection:UIRectCornerAllCorners cornerRadius:18];
    
    [self.searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.centerY.mas_equalTo(self.searchView);
    }];

    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIconImageView.mas_right).mas_offset(10);
        make.right.mas_equalTo(-7);
        make.centerY.mas_equalTo(self.searchView);
        make.top.mas_equalTo(self.searchView);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.searchView);
        make.right.mas_equalTo(-11);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.searchIconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityRequired
                                         forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)p_clickCancelButton{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCancelButtonForSearchNavigaitonBarView:)]) {
        [self.delegate onClickCancelButtonForSearchNavigaitonBarView:self];
    }
}

#pragma mark -- initSubviews

- (UIView *)searchView{
    if (!_searchView) {
        _searchView = [[UIView alloc]init];
        _searchView.backgroundColor = [UIColor colorWithHexStr:PPButtonUnableColorValue];
        [self addSubview:_searchView];
    }
    return _searchView;
}

- (UIImageView *)searchIconImageView{
    if (!_searchIconImageView) {
        _searchIconImageView = [[UIImageView alloc]init];
        _searchIconImageView.image = [UIImage imageNamed:@"icon_home_search"];
        [self.searchView addSubview:_searchIconImageView];
    }
    return _searchIconImageView;
}

- (PPTextField *)searchTextField{
    if (!_searchTextField) {
        _searchTextField = [[PPTextField alloc]init];
        _searchTextField.textAlignment = NSTextAlignmentLeft;
        _searchTextField.font = UIFont.systemFont(PPMainBodyFontValue);
        _searchTextField.textColor = [UIColor colorWithHexStr:PPTitleColorValue];
        _searchTextField.returnKeyType = UIReturnKeySearch;
//        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc]initWithString:@"请输入书籍名称、作者或出版社"
//                                                                                        attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexStr:PPAssistTextColorValue],
//                                                                                                     NSFontAttributeName:UIFont.systemFont(13)}];
//        _searchTextField.attributedPlaceholder = placeholder;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextField.delegate = self;
        [self.searchView addSubview:_searchTextField];
    }
    return _searchTextField;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexStr:PPTitleColorValue] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = UIFont.systemFont(15);
        [_cancelButton addTarget:self action:@selector(p_clickCancelButton) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

-(UIView*)line{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor colorWithHexStr:PPLineColorValue];
        [self addSubview:_line];
    }
    return _line;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length < 1) {
        return NO;
    }
    [self endEditing:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchNavigaitonBarView:beginSearchWithSearchText:)]) {
        [self.delegate searchNavigaitonBarView:self beginSearchWithSearchText:textField.text];
    }
    return YES;
}

-(void)searchbBecomeFirstResponder{
    [self.searchTextField becomeFirstResponder];
}

- (void)setIsChild:(BOOL)isChild {
    _isChild = isChild;
    if (!isChild) {
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc]initWithString:@"请输入书籍名称、作者或出版社1"
                                                                                        attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexStr:PPAssistTextColorValue],
                                                                                                     NSFontAttributeName:UIFont.systemFont(13)}];
        self.searchTextField.attributedPlaceholder = placeholder;
    }
}

@end
