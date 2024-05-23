//
//  SearchNavigationBarView.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "SearchNavigationBarView.h"
#import "Masonry.h"
#import "YHSearchConst.h"

@interface SearchNavigationBarView ()<UITextFieldDelegate>
@property(nonatomic,strong)UIView * line;

@end

@implementation SearchNavigationBarView

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
        make.right.mas_equalTo(self.cancelButton.mas_left);
        make.height.mas_equalTo(36);
    }];
   
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
        make.left.mas_equalTo(self.searchView.mas_right);
        make.right.mas_equalTo(self);
        make.width.mas_equalTo(60);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.searchIconImageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityRequired
                                         forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark -- initSubviews

- (UIView *)searchView{
    if (!_searchView) {
        _searchView = [[UIView alloc]init];
        _searchView.layer.cornerRadius  =18;
        _searchView.backgroundColor = [UIColor yh_colorWithHexString:@"#F4F4F4"];
        [self addSubview:_searchView];
    }
    return _searchView;
}

- (UIImageView *)searchIconImageView{
    if (!_searchIconImageView) {
        _searchIconImageView = [[UIImageView alloc]init];
        _searchIconImageView.image = [NSBundle yh_imageNamed:@"search"];
        [self.searchView addSubview:_searchIconImageView];
    }
    return _searchIconImageView;
}

- (UITextField *)searchTextField{
    if (!_searchTextField) {
        _searchTextField = [[UITextField alloc]init];
        _searchTextField.textAlignment = NSTextAlignmentLeft;
        _searchTextField.font = [UIFont systemFontOfSize:14];
        _searchTextField.textColor = [UIColor blackColor];
        _searchTextField.returnKeyType = UIReturnKeySearch;
        NSMutableAttributedString * placeholder = [[NSMutableAttributedString alloc]initWithString:@""  attributes:@{NSForegroundColorAttributeName:[UIColor yh_colorWithHexString:@"#BABABA"],
                                                                                                                                   NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        _searchTextField.attributedPlaceholder = placeholder;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTextField.delegate = self;
        
        [_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        [self.searchView addSubview:_searchTextField];
    }
    return _searchTextField;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:[NSBundle yh_localizedStringForKey:YHSearchCancelButtonText] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor yh_colorWithHexString:@"#000000"] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton addTarget:self action:@selector(p_clickCancelButton) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

-(UIView*)line{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor yh_colorWithHexString:@"#DDDDDD"];
        [self addSubview:_line];
    }
    return _line;
}

-(void)searchBecomeFirstResponder{
    [self.searchTextField becomeFirstResponder];
}

/**
 searchTextField失去第一响应者
 */
-(void)searchResignFirstResponder{
    
    [self.searchTextField resignFirstResponder];
}

//MARK:点击取消按钮
- (void)p_clickCancelButton{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickCancelButtonForSearchNavigaitonBarView:)]) {
        [self.delegate onClickCancelButtonForSearchNavigaitonBarView:self];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchNavigaitonBarViewByTextFieldShouldBeginEditing:)]) {
        return  [self.delegate searchNavigaitonBarViewByTextFieldShouldBeginEditing:textField];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length < 1) {
        return NO;
    }
    [self endEditing:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchNavigaitonBarViewByTextFieldShouldReturn:)]) {
        return [self.delegate searchNavigaitonBarViewByTextFieldShouldReturn:textField];
    }
    return NO;
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchNavigaitonBarViewByTextFieldShouldClear:)]) {
        return  [self.delegate searchNavigaitonBarViewByTextFieldShouldClear:textField];
    }
    return  NO;
    
}

-(void)textFieldDidChange:(UITextField *)textField {

    if (self.delegate && [self.delegate respondsToSelector:@selector(searchNavigaitonBarViewByTextFieldDidChange:)]) {
        return  [self.delegate searchNavigaitonBarViewByTextFieldDidChange:textField];
    }
}


@end
