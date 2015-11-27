//
//  ICEPhotoActionSheet.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/11.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEPhotoActionSheet.h"
#import "ICEPhotoGroupViewController.h"
#import "ICEThumbnailView.h"
#import "ICEAssetManager.h"

@interface ICEPhotoActionSheet () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong, getter = getSheetView)    UIView   *sheetView;
@property (nonatomic, strong, getter = getButtonAlbum)  UIButton *btnAlbum;
@property (nonatomic, strong, getter = getButtonCamera) UIButton *btnCamera;
@property (nonatomic, strong, getter = getButtonCancel) UIButton *btnCancel;
@property (nonatomic, strong, getter = getThumbnailView) ICEThumbnailView *thumbnailView;
@property (nonatomic, weak) UIViewController *weakSuper;    ///< 需要这个ViewCtrl作为其他视图控制器的跳转控制器
@end

@implementation ICEPhotoActionSheet

- (instancetype)initWithMaxSelected:(NSInteger )maxSelected weakSuper:(id)weakSuper {
    self = [super init];
    if (self) {
        [ICEAssetManager sharedInstance].maxSelected = maxSelected;
        [ICEAssetManager sharedInstance].hasOriginal = NO;
        self.weakSuper = weakSuper;
        [self addSubview];
        [self configUI];
        return self;
    }
    return self;
}

/** 将当前 View 添加到 Ctrl 的 View 上 */
-(void)addSubview {
    UIViewController *toVC = [self appRootViewController];
    if (toVC.tabBarController != nil) {
        [toVC.tabBarController.view addSubview:self];
    }else if (toVC.navigationController != nil){
        [toVC.navigationController.view addSubview:self];
    }else{
        [toVC.view addSubview:self];
    }
}

- (UIViewController *)appRootViewController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)dealloc{
    _weakSuper = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[ICEAssetManager sharedInstance] clearData];
}

#pragma mark - life cycle

- (void)configUI {
    self.alpha = 0;
    [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    [self addSubview:self.sheetView];
    [self.sheetView addSubview:self.btnCancel];
    [self.sheetView addSubview:self.btnAlbum];
    [self.sheetView addSubview:self.btnCamera];
    [self.sheetView addSubview:self.thumbnailView];
    
    [self configNotification];
}

- (void)configNotification{
    // 发送照片通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSendPhotos:) name:kNotificationSendPhotos object:nil];
    // 更新选中照片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationUpdateSelected:) name:kNotificationUpdateSelected object:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.weakSuper dismissViewControllerAnimated:YES completion:^{
        //        [self sendImageArray:@[editedImage]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.weakSuper dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Custom Deledate

/** 发送照片 */
- (void)sendImageArray:(NSArray *)ary{
    if (_delegate && [_delegate respondsToSelector:@selector(actionSheetDidFinished:)]) {
        [_delegate actionSheetDidFinished:ary];
    }
    // 照片发送后
    // 将选中的照片从数组中移除
    [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
    [self compleRemoveFromSuperview];
}

#pragma mark - Event Response
/** 取消 */
- (void)onClickCancel:(UIButton *)btn {
    // 将选中的照片从数组中移除
    [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
    [self compleRemoveFromSuperview];
}

/** 拍照 */
- (void)onClickCamera:(UIButton *)btn {
    // 有   选择照片
    if (_btnCamera.selected == NO) {
        [self notificationSendPhotos:nil];
        return;
    }
    // 没有 系统相机
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    [self.weakSuper presentViewController:pickerImage animated:YES completion:^{
        // 将选中的照片从数组中移除
        [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
        [self compleRemoveFromSuperview];
    }];
}

/** 相册 */
- (void)onClickAlbum:(UIButton *)btn {
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:[ICEPhotoGroupViewController new]];
    [self.weakSuper presentViewController:naviController animated:YES completion:^{
        [self cancelAnimation:nil];
    }];
}

/** 触摸事件 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 将选中的照片从数组中移除
    [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
    [self compleRemoveFromSuperview];
}

#pragma mark - Public Methods

/** 显示 */
- (void)showPhotoActionSheet {
    _btnCamera.selected = YES;
    CGRect frame = _sheetView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height -335;
    [UIView animateWithDuration:.25f animations:^{
        _sheetView.frame = frame;
        self.alpha = 1;
    }];
}

#pragma mark - Private Methods

/** 发送照片 */
- (void)notificationSendPhotos:(NSNotification *)noti {
    BOOL isOr = [ICEAssetManager sharedInstance].isOriginal;
    [self sendImageArray:[[ICEAssetManager sharedInstance] sendSelectedPhotos:isOr ? 4 : 3]];
    [self.weakSuper dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)compleRemoveFromSuperview {
    [self cancelAnimation:^{
        // 释放掉
        [self removeFromSuperview];
    }];
}

/** 隐藏 */
- (void)cancelAnimation:(void (^)(void))comple {
    CGRect frame = _sheetView.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:.25f animations:^{
        _sheetView.frame = frame;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (comple) {
            comple();
        }
    }];
}

/** 修改相机按钮的名词 通过这个按钮是否被选中来判断*/
- (void)notificationUpdateSelected:(NSNotification *)note {
    NSInteger count = [[ICEAssetManager sharedInstance] getSelectedPhotoCount];
    if (count == 0) {
        _btnCamera.selected = YES;
        [_btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
        return;
    }
    _btnCamera.selected = NO;
    NSString *name = [NSString stringWithFormat:@"发送(%ld)张",count];
    [_btnCamera setTitle:name forState:UIControlStateNormal];
}

#pragma mark - Getters And Setters

/** 底板SheetView*/
- (UIView *)getSheetView{
    if (_sheetView == nil) {
        CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 335);
        _sheetView = [[UIView alloc] initWithFrame:frame];
        _sheetView.backgroundColor = [UIColor lightGrayColor];
    }
    return _sheetView;
}

/** 取消 */
- (UIButton *)getButtonCancel {
    if (_btnCancel == nil) {
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCancel.frame = CGRectMake(0, CGRectGetHeight(_sheetView.frame) - 49.5, [UIScreen mainScreen].bounds.size.width, 49.5);
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _btnCancel.backgroundColor = [UIColor whiteColor];
        [_btnCancel addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}

/** 相册 */
- (UIButton *)getButtonAlbum {
    
    if (_btnAlbum == nil) {
        _btnAlbum = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnAlbum.frame = CGRectMake(0, CGRectGetMinY(_btnCancel.frame) - 50, [UIScreen mainScreen].bounds.size.width, 49.5);
        [_btnAlbum setTitle:@"相册" forState:UIControlStateNormal];
        [_btnAlbum setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _btnAlbum.backgroundColor = [UIColor whiteColor];
        [_btnAlbum addTarget:self action:@selector(onClickAlbum:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAlbum;
}

/** 拍照 */
- (UIButton *)getButtonCamera {
    if (_btnCamera == nil) {
        _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCamera.frame = CGRectMake(0, CGRectGetMinY(_btnAlbum.frame) - 50, [UIScreen mainScreen].bounds.size.width, 49.5);
        [_btnCamera setTitle:@"拍照" forState:UIControlStateNormal];
        [_btnCamera setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _btnCamera.backgroundColor = [UIColor whiteColor];
        [_btnCamera addTarget:self action:@selector(onClickCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCamera;
}

/** 缩略图 */
- (ICEThumbnailView *)getThumbnailView {
    if (_thumbnailView == nil) {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 185);
        _thumbnailView = [[ICEThumbnailView alloc] initWithFrame:frame];
    }
    return _thumbnailView;
}

@end
