//
//  YHSearchNavigationBarView.m
//  YHSearch_Example
//
//  Created by Yihua Liu on 2020/11/18.
//  Copyright © 2020 liuyihua2015@sina.com. All rights reserved.
//

#import "YHSearchNavigationBarView.h"
#import "YHSearchConst.h"

@interface YHSearchNavigationBarView ()<UITextFieldDelegate>
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
    
    CGFloat cancelWidth = 50;
    
    self.searchView.frame = CGRectMake(10, YH_StatusBarHeight + 4, YHScreenW - 20 - cancelWidth, 36);
    
    self.searchIconImageView.frame = CGRectMake(10, 0, 16, 36);
    
    self.searchTextField.frame = CGRectMake(CGRectGetMaxX(self.searchIconImageView.frame) + 10, 0, self.searchView.yh_width - self.searchIconImageView.yh_height - 10, 36);
    
    self.cancelButton.frame = CGRectMake(YHScreenW - 10 - cancelWidth, 0, cancelWidth, 36);
    self.cancelButton.yh_centerY = self.searchView.yh_centerY;
    
    self.line.frame = CGRectMake(0, YH_NavgationFullHeight - 1, self.yh_width, 0.5);
    
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
        _searchIconImageView.contentMode = UIViewContentModeScaleAspectFit;
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
    if(self.alpha > 0) {
        [self.searchTextField becomeFirstResponder];
    }
}

/**
 searchTextField失去第一响应者
 */
-(void)searchResignFirstResponder{
    if(self.alpha > 0) {
        [self.searchTextField resignFirstResponder];
    }
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
