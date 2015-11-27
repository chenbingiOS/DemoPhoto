//
//  ICEThumbnailCheckCell.m
//  DemoPhoto
//
//  Created by ttouch on 15/11/23.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEThumbnailCheckCell.h"
#import "ICEAssetManager.h"

@interface ICEThumbnailCheckCell ()
@property (nonatomic, strong, getter=getImageSelected) UIImageView *imgSelected;
@property (nonatomic, assign) BOOL isCheckSelected;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end
@implementation ICEThumbnailCheckCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self configUI];
    }
    return self;
}

- (void)awakeFromNib {
    [self configUI];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _imgSelected.image = nil;
    _isCheckSelected = NO;
}

#pragma mark - life cycle
- (void)configUI {
    [self addSubview:self.imgSelected];
}
#pragma mark - life cycle

#pragma mark - UICollectionView Delegate

#pragma mark - Event Response

#pragma mark - Public Methods

- (void)setContentWithIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    [self setIsCheckSelected:[[ICEAssetManager sharedInstance] isSelectdPhotosWithIndex:indexPath.row]];
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

#pragma mark - Private Methods
- (void)handleSingleTap:(UITapGestureRecognizer *)gesture{
    [self setContentSelected];
}

- (void)setContentSelected{
    NSInteger max = [ICEAssetManager sharedInstance].maxSelected;
    if (!_isCheckSelected && [ICEAssetManager sharedInstance].selectdPhotos.count >= max) {
        NSString *title = [NSString stringWithFormat:@"您最多只能选择%d张图片",(int)max];
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
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
- (UIImageView *)getImageSelected {
    if (_imgSelected == nil) {
        _imgSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        _imgSelected.contentMode = UIViewContentModeScaleAspectFill;
        _imgSelected.userInteractionEnabled = YES;
        _imgSelected.clipsToBounds = YES;
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_imgSelected addGestureRecognizer:singleRecognizer];
    }
    return _imgSelected;
}
@end
