//
//  ICEToolBarView.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/18.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEToolBarView.h"
#import "ICEAssetManager.h"

@interface ICEToolBarView ()
@property (nonatomic, strong, getter = getButtonPreview)        UIButton *btnPreview;   ///<预览
@property (nonatomic, strong, getter = getButtonEdit)           UIButton *btnEdit;      ///<编辑
@property (nonatomic, strong, getter = getButtonOriginalImage)  UIButton *btnOriginal;  ///<原图
@property (nonatomic, strong, getter = getButtonSend)           UIButton *btnSend;      ///<发送

@end

@implementation ICEToolBarView

- (instancetype)initWithWhiteColor {
    if (self = [super init]) {
        [self configWhiteColorUI];
    }
    return self;
}

- (instancetype)initWithBlackColor {
    if (self = [super init]) {
        [self configBlackColorUI];
    }
    return self;
}

#pragma mark - life cycle
- (void)configWhiteColorUI {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    
    [self addSubview:self.btnPreview];
    [self addSubview:self.btnEdit];
    [self addSubview:self.btnOriginal];
    [self addSubview:self.btnSend];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self configNotification];
}

- (void)configBlackColorUI {
    [self addSubview:self.btnEdit];
    [self addSubview:self.btnSend];
    [self addSubview:self.btnOriginal];
    _btnEdit.frame = CGRectMake(10, 0, 50, 50);
    _btnOriginal.frame = CGRectMake(70, 0, 120, 50);
    self.backgroundColor = [UIColor darkGrayColor];
    
    [self configNotification];
}

- (void)configNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdateSelected:) name:kNotificationUpdateSelected object:nil];
    
    [self notificationUpdateSelected:nil];
}

#pragma mark - Custom Deledate

#pragma mark - Event Response
/** 预览按钮事件添加 */
- (void)addPreviewTarget:(id)target action:(SEL)action{
    [_btnPreview addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)onClickOriginal:(UIButton *)sender{
    sender.selected = !sender.selected ? YES : NO;
    // 设置为原图
    [ICEAssetManager sharedInstance].hasOriginal = sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateSelected object:nil];
}

- (void)onClickSend:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendPhotos object:nil];
}

#pragma mark - Public Methods

#pragma mark - Private Methods

- (void)updateBtnOriginal {
    NSString *titleKB = [[ICEAssetManager sharedInstance] getSelectdPhotosSize];
    NSString *title = [NSString stringWithFormat:@" 原图(%@)",titleKB];
    [_btnOriginal setTitle:title forState:UIControlStateNormal];
}

- (void)notificationUpdateSelected:(NSNotification *)noti{
    UIColor *colorEn = [UIColor colorWithRed:59/255.0 green:183/255.0 blue:246/255.0 alpha:1];
    UIColor *colorNo = [UIColor lightGrayColor];
    NSInteger count = [[ICEAssetManager sharedInstance] getSelectedPhotoCount];
    if (count == 0) {
        _btnPreview.enabled = _btnEdit.enabled = _btnOriginal.enabled = _btnSend.enabled = NO;
        [_btnPreview setTitleColor:colorNo forState:UIControlStateNormal];
        [_btnEdit setTitleColor:colorNo forState:UIControlStateNormal];
        [_btnOriginal setTitleColor:colorNo forState:UIControlStateNormal];
        
        NSString *name = [NSString stringWithFormat:@"发送"];
        [_btnSend setTitle:name forState:UIControlStateNormal];
        _btnSend.backgroundColor = colorNo;
        
        [_btnOriginal setTitle:@" 原图" forState:UIControlStateNormal];
        return;
    } else {
        _btnPreview.enabled = _btnEdit.enabled = _btnOriginal.enabled = _btnSend.enabled = YES;
        [_btnPreview setTitleColor:colorEn forState:UIControlStateNormal];
        [_btnEdit setTitleColor:colorEn forState:UIControlStateNormal];
        [_btnOriginal setTitleColor:colorEn forState:UIControlStateNormal];
        // 更新提交按钮
        NSString *name = [NSString stringWithFormat:@"发送(%ld)",(long)count];
        [_btnSend setTitle:name forState:UIControlStateNormal];
        _btnSend.backgroundColor = colorEn;
        
        if ([ICEAssetManager sharedInstance].isOriginal) {
            _btnOriginal.selected = YES;
            // 更新原图按钮
            [self updateBtnOriginal];
        } else {
            _btnOriginal.selected = NO;
            [_btnOriginal setTitle:@" 原图" forState:UIControlStateNormal];
        }
        
        if (count >= 2) {
            _btnEdit.enabled = NO;
            [_btnEdit setTitleColor:colorNo forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Getters And Setters

- (UIButton *)getButtonPreview{
    if (_btnPreview == nil) {
        _btnPreview = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnPreview.frame = CGRectMake(10, 0, 50, 50);
        [_btnPreview setTitle:@"预览" forState:UIControlStateNormal];
        UIColor *color = [UIColor lightGrayColor];
        [_btnPreview setTitleColor:color forState:UIControlStateNormal];
        _btnPreview.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnPreview.enabled = NO;
    }
    return _btnPreview;
}

- (UIButton *)getButtonEdit {
    if (_btnEdit == nil) {
        _btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnEdit.frame = CGRectMake(60, 0, 50, 50);
        [_btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        UIColor *color = [UIColor lightGrayColor];
        [_btnEdit setTitleColor:color forState:UIControlStateNormal];
        _btnEdit.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnEdit.enabled = NO;
        //        [_btnEdit addTarget:self action:@selector(onClickOriginal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnEdit;
}

- (UIButton *)getButtonOriginalImage{
    if (_btnOriginal == nil) {
        _btnOriginal = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnOriginal.frame = CGRectMake(120, 0, 120, 50);
        [_btnOriginal setTitle:@" 原图" forState:UIControlStateNormal];
        UIColor *color = [UIColor lightGrayColor];
        [_btnOriginal setTitleColor:color forState:UIControlStateNormal];
        _btnOriginal.titleLabel.font = [UIFont systemFontOfSize:16];
        [_btnOriginal setImage:[UIImage imageNamed:@"OImageSelectedOff"] forState:UIControlStateNormal];
        [_btnOriginal setImage:[UIImage imageNamed:@"OImageSelectedOn"] forState:UIControlStateSelected];
        _btnOriginal.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _btnOriginal.enabled = NO;
        _btnOriginal.selected = [ICEAssetManager sharedInstance].isOriginal;
        [_btnOriginal addTarget:self action:@selector(onClickOriginal:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnOriginal;
}

- (UIButton *)getButtonSend{
    if (_btnSend == nil) {
        _btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnSend.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 84, 10, 70, 30);
        [_btnSend setTitle:@"发送" forState:UIControlStateNormal];
        UIColor *color = [UIColor whiteColor];
        [_btnSend setTitleColor:color forState:UIControlStateNormal];
        _btnSend.titleLabel.font = [UIFont systemFontOfSize:16];
        _btnSend.backgroundColor = [UIColor lightGrayColor];
        _btnSend.layer.cornerRadius = 4;
        _btnSend.layer.masksToBounds = YES;
        _btnSend.enabled = NO;
        [_btnSend addTarget:self action:@selector(onClickSend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSend;
}

@end
