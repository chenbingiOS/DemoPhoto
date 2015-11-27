//
//  ICEPhotoCollectionViewCell.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/18.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEPhotoCollectionViewCell.h"
#import "ICEAssetManager.h"

@interface ICEPhotoCollectionViewCell ()

@property (nonatomic, strong, getter = getImageThumbnails)  UIImageView *imgThumbnails;
@property (nonatomic, strong, getter = getImageSelected)    UIImageView *imgSelected;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isCheckSelected;

@end

@implementation ICEPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _imgThumbnails.image = nil;
    _isCheckSelected = NO;
}

#pragma mark - life cycle

- (void)configUI{
    [self addSubview:self.imgThumbnails];
    [self addSubview:self.imgSelected];
}

#pragma mark - Custom Deledate

#pragma mark - Event Response

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture{
    CGPoint location = [gesture locationInView:self];
    if ([self isContainsPointWithPoint:location]) {
        [self setContentSelected];
    }
}

- (void)setContentWithIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    self.imgThumbnails.image = [[ICEAssetManager sharedInstance] getImageAtIndex:indexPath.row type:1];
    [self setIsCheckSelected:[[ICEAssetManager sharedInstance] isSelectdPhotosWithIndex:indexPath.row]];
}

- (void)setContentSelected{
    NSInteger max = [ICEAssetManager sharedInstance].maxSelected;
    if (!_isCheckSelected && [ICEAssetManager sharedInstance].selectdPhotos.count >= max) {        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"您最多只能选择%d张图片",(int)max] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alter show];
        return;
    }

    if (!_isCheckSelected) {
        [[ICEAssetManager sharedInstance] addObjectWithIndex:_indexPath.row];       // 给选中数组添加
        [self setIsCheckSelected:YES];
    }else{
        [[ICEAssetManager sharedInstance] removeObjectWithIndex:_indexPath.row];    // 从选中数组移除
        [self setIsCheckSelected:NO];
    }
}

#pragma mark - Public Methods

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

#pragma mark - Private Methods

- (BOOL )isContainsPointWithPoint:(CGPoint )location{
    CGFloat x = CGRectGetMinX(_imgSelected.frame)   -5;
    CGFloat y = CGRectGetMinY(_imgSelected.frame)   -5;
    CGFloat w = CGRectGetWidth(_imgSelected.frame)  +10;
    CGFloat h = CGRectGetHeight(_imgSelected.frame) +10;
    // 判断一个 CGPoint 是否包含再另一个 View 的 CGRect 里面,常用与测试给定的对象之间是否又重叠
    return CGRectContainsPoint(CGRectMake(x, y, w, h), location);
}

- (void)setIsCheckSelected:(BOOL)isCheckSelected{
    if (isCheckSelected) {
        _imgSelected.image = [UIImage imageNamed:@"ImageSelectedOn"];
        _imgSelected.transform = CGAffineTransformMakeScale(.5f, .5f);
        [UIView animateWithDuration:.3f
                              delay:0
             usingSpringWithDamping:.5f
              initialSpringVelocity:.5f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _imgSelected.transform = CGAffineTransformIdentity;
                         } completion:nil];
    } else {
        _imgSelected.image = [UIImage imageNamed:@"ImageSelectedOff"];
    }
    _isCheckSelected = isCheckSelected;
}

#pragma mark - Getters And Setters

- (UIImageView *)getImageThumbnails{
    if (_imgThumbnails == nil) {
        _imgThumbnails = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgThumbnails.contentMode = UIViewContentModeScaleAspectFill;
        _imgThumbnails.clipsToBounds = YES;
    }
    return _imgThumbnails;
}


- (UIImageView *)getImageSelected {
    if (_imgSelected == nil) {
        _imgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) -28, CGRectGetHeight(self.frame) - 28, 24, 24)];
        _imgSelected.contentMode = UIViewContentModeScaleAspectFill;
        _imgSelected.userInteractionEnabled = YES;
        _imgSelected.clipsToBounds = YES;
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_imgSelected addGestureRecognizer:singleRecognizer];
    }
    return _imgSelected;
}
@end
