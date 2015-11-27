//
//  ICEPhotoCollectionViewController.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/12.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEPhotoCollectionViewController.h"
#import "ICEAssetManager.h"
#import "ICEPhotoCollectionViewCell.h"
#import "ICEToolBarView.h"
#import "ICEPhotoBrowserViewController.h"

@interface ICEPhotoCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ICEPhotoBrowserDelegate>
@property (nonatomic, strong, getter = getCollectionView) UICollectionView  *collectionView;
@property (nonatomic, strong, getter = getToolBarView)    ICEToolBarView    *toolBarView;

@property (nonatomic, assign) NSInteger jumpPage;
@property (nonatomic, assign) BOOL      isPreview;
@end

@implementation ICEPhotoCollectionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationItem];
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - life cycle
- (void)configUI{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolBarView];
}

- (void)configNavigationItem{
    self.navigationItem.title = @"相册";
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onClickCancel:)];
    
    self.navigationItem.rightBarButtonItem = barCancel;
}
#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 从照片集合中的某个组里面取出这个组的照片重个数
    return [[ICEAssetManager sharedInstance] getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ICEPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ICEPhotoCollectionViewCell cellReuseIdentifier] forIndexPath:indexPath];
    // 在 Cell 里面进行值判定
    [cell setContentWithIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{    
    _jumpPage = indexPath.row;
    
    ICEPhotoBrowserViewController *iCEPhotoBrowser = [[ICEPhotoBrowserViewController alloc] init];
    iCEPhotoBrowser.delegate = self;
    [self.navigationController pushViewController:iCEPhotoBrowser animated:YES];
}

#pragma mark - UUPhotoBrowser Delegate

- (BOOL)isCheckMaxSelectedFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser{
    NSInteger max = [ICEAssetManager sharedInstance].maxSelected;
    if ([ICEAssetManager sharedInstance].selectdPhotos.count >= max) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"您最多只能选择%d张图片",(int)max]
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确认", nil];
        [alter show];
    }
    return [ICEAssetManager sharedInstance].selectdPhotos.count >= max ? YES : NO;
}

- (void)displayImageWithIndex:(NSUInteger)index selectedChanged:(BOOL)selected{
    
    if (_isPreview) {
        index = [[ICEAssetManager sharedInstance] markPreviewObjectWithIndex:index selecte:selected];
    } else  {
         if (selected) {
            [[ICEAssetManager sharedInstance] addObjectWithIndex:index];
         } else {
             [[ICEAssetManager sharedInstance] removeObjectWithIndex:index];
         }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (UIImage *)displayImageWithIndex:(NSInteger)index fromPhotoBrowser:(ICEPhotoBrowserViewController *)browser{
    if (_isPreview) {
        return [[ICEAssetManager sharedInstance] getImagePreviewAtIndex:index type:3];
    }
    return [[ICEAssetManager sharedInstance] getImageAtIndex:index type:3];
}

- (NSInteger)numberOfPhotosFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser{
    if (_isPreview) {
        return [ICEAssetManager sharedInstance].selectdPhotos.count;
    }
    return [ICEAssetManager sharedInstance].assetPhotos.count;
}

- (BOOL)isSelectedPhotosWithIndex:(NSInteger)index fromPhotoBrowser:(ICEPhotoBrowserViewController *)browser{
    if (_isPreview) {
        return [[ICEAssetManager sharedInstance] isSelectdPreviewWithIndex:index];
    }
    return [[ICEAssetManager sharedInstance] isSelectdPhotosWithIndex:index];
}

- (NSInteger)jumpIndexFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser{
    return _jumpPage;
}

#pragma mark - Custom Deledate

#pragma mark - Event Response

- (void)onClickCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        // 将选中的照片从数组中移除
        [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
    }];
}

- (void)onClickPreview:(id)sender{
    _jumpPage = 0;
    _isPreview = YES;

    ICEPhotoBrowserViewController *iCEPhotoBrowser = [[ICEPhotoBrowserViewController alloc] init];
    iCEPhotoBrowser.delegate = self;
    [self.navigationController pushViewController:iCEPhotoBrowser animated:YES];
}

#pragma mark - Public Methods

#pragma mark - Private Methods

- (void)scrollToSelectedItem{
    NSInteger index = [[ICEAssetManager sharedInstance] currentGroupFirstIndex];
    if (index > 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    }
}

#pragma mark - Getters And Setters

- (UICollectionView *)getCollectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 3;
        NSInteger size = [UIScreen mainScreen].bounds.size.width / 4 -1;
        if (size % 2 != 0) {
            size -= 1;
        }
        flowLayout.itemSize = CGSizeMake(size, size);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        CGRect frame = CGRectMake(0, 3, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.view.frame) - 50 - 3);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        
        [_collectionView registerClass:[ICEPhotoCollectionViewCell class] forCellWithReuseIdentifier:[ICEPhotoCollectionViewCell cellReuseIdentifier]];
        
        // 从照片集合中，通过选中的组索引获取对应组的所有照片，刷新UI
        [[ICEAssetManager sharedInstance]
         getPhotoListOfGroupByIndex:[ICEAssetManager sharedInstance].currentGroupIndex
         result:^(NSArray *obj) {
             [_collectionView reloadData];             
             [self scrollToSelectedItem];
         } isOrder:YES];
    }
    return _collectionView;
}

- (ICEToolBarView *)getToolBarView{
    if (_toolBarView == nil) {
        CGRect frame = CGRectMake(0, CGRectGetHeight(self.view.frame) -50, [UIScreen mainScreen].bounds.size.width, 50);
        _toolBarView = [[ICEToolBarView alloc] initWithWhiteColor];
        _toolBarView.frame = frame;
        [_toolBarView addPreviewTarget:self action:@selector(onClickPreview:)];
    }
    return _toolBarView;
}
@end
