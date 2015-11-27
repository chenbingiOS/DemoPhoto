//
//  ICEThumbnailView.m
//  DemoPhoto
//
//  Created by ttouch on 15/11/23.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEThumbnailView.h"
#import "ICEAssetManager.h"
#import "ICEThumbnailCollectionViewCell.h"
#import "ICEThumbnailCheckCell.h"
#import "ICEThumbnailFlowLayout.h"

@interface ICEThumbnailView()< UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong, getter = getCollectionView) UICollectionView *collectionView;
@end

@implementation ICEThumbnailView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self configUI];
    }
    return self;
}

#pragma mark - life cycle

- (void)configUI{
    [self addSubview:self.collectionView];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[ICEAssetManager sharedInstance] getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ICEThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ICEThumbnailCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
    [cell setContentWithIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

/** 添加一个补充视图(页眉或页脚) */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ICEThumbnailCheckCell *checkView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[ICEThumbnailCheckCell cellReuseIdentifier] forIndexPath:indexPath];
    [checkView setContentWithIndexPath:indexPath];
    //    [self.indexPathToCheckViewTable setObject:checkView forKey:indexPath];
    
    //    if ([self.IndexPathArr containsObject:indexPath]) {
    //        [checkView setChecked:YES];
    //    }else{
    //        [checkView setChecked:FALSE];
    //    }
    return checkView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
//    ICEThumbnailCollectionViewCell *cell = (ICEThumbnailCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [cell setContentSelected];
}

#pragma mark - UICollectionViewDelegateFlowLayout 
/** 让格子保存宽高比 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath; {
    UIImage *imageAtPath = [[ICEAssetManager sharedInstance] getImageAtIndex:indexPath.row type:2];;
    
    CGFloat imageHeight = imageAtPath.size.height;
    CGFloat viewHeight = collectionView.bounds.size.height;
    CGFloat scaleFactor = viewHeight/imageHeight;
    // 保持比例
    CGSize scaledSize = CGSizeApplyAffineTransform(imageAtPath.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    return scaledSize;
}

#pragma mark - Custom Deledate

#pragma mark - Event Response

#pragma mark - Public Methods

#pragma mark - Private Methods

#pragma mark - Getters And Setters

- (UICollectionView *)getCollectionView{
    if (_collectionView == nil) {
        ICEThumbnailFlowLayout *flowLayout= [[ICEThumbnailFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 4;

        CGRect frame = CGRectMake(0, 4, [UIScreen mainScreen].bounds.size.width, 185 - 8);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.allowsSelection = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        
        [_collectionView registerClass:[ICEThumbnailCollectionViewCell class]
            forCellWithReuseIdentifier:[ICEThumbnailCollectionViewCell cellReuseIdentifier]];
        [_collectionView registerClass:[ICEThumbnailCheckCell class] forSupplementaryViewOfKind:@"check" withReuseIdentifier:[ICEThumbnailCheckCell cellReuseIdentifier]];

        // 先获取分组
        [[ICEAssetManager sharedInstance] getGroupList:^(NSArray *ary) {
            // 再获取对应分组里面的照片
            [[ICEAssetManager sharedInstance] getPhotoListOfGroupByIndex:[ICEAssetManager sharedInstance].currentGroupIndex result:^(NSArray *ary) {
                [_collectionView reloadData];
            } isOrder:NO];
        }];
    }
    return _collectionView;
}

@end
