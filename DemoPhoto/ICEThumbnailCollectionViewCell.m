//
//  ICEThumbnailCollectionViewCell.m
//  DemoPhoto
//
//  Created by ttouch on 15/11/23.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEThumbnailCollectionViewCell.h"
#import "ICEAssetManager.h"

@interface ICEThumbnailCollectionViewCell ()

@property (nonatomic, strong, getter=getImageView) UIImageView *imageView;

@end

@implementation ICEThumbnailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self configUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configUI];
}
- (void)prepareForReuse{
    [super prepareForReuse];
    _imageView.image = nil;
}

#pragma mark - life cycle
- (void)configUI {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.imageView];
    // 保证图片铺满格子
    UIImageView *imageView = self.imageView;
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
}


#pragma mark - UICollectionView Delegate

#pragma mark - Event Response

#pragma mark - Public Methods

- (void)setContentWithIndexPath:(NSIndexPath *)indexPath{
    self.imageView.image = [[ICEAssetManager sharedInstance] getImageAtIndex:indexPath.row type:2];
}

+ (NSString *)cellReuseIdentifier{
    return NSStringFromClass([self class]);
}

#pragma mark - Private Methods

#pragma mark - Getters And Setters

- (UIImageView *)getImageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.layer.cornerRadius = 1.0f;
        _imageView.layer.masksToBounds = true;
    }
    return _imageView;
}
@end
