//
//  ICEPhotoGroupViewController.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/12.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEPhotoGroupViewController.h"
#import "ICEAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ICEPhotoCollectionViewController.h"

@interface ICEPhotoGroupViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, getter = getTableView) UITableView *tableView;
@end

@implementation ICEPhotoGroupViewController

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
    [self.view addSubview:self.tableView];
    // 从照片集合中获取组的数据，默认进入格子列表给用户选择
    [[ICEAssetManager sharedInstance] getGroupList:^(NSArray *obj) {
        [self.tableView reloadData];
        [self.navigationController pushViewController:ICEPhotoCollectionViewController.new animated:NO];
    }];
}

- (void)configNavigationItem{    
    self.navigationItem.title = @"照片";
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel:)];
    self.navigationItem.rightBarButtonItem = barCancel;
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 从照片集合中获取组个数
    return [[ICEAssetManager sharedInstance] getGroupCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    // 从照片集合中，取出对应组资料
    ALAssetsGroup *group  = [[ICEAssetManager sharedInstance] getGroupAtIndex:indexPath.row];
    cell.imageView.image  = [UIImage imageWithCGImage:[group posterImage]];
    cell.textLabel.text   = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[group numberOfAssets]];
    cell.accessoryType    = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 设置当前选中的分组
    [ICEAssetManager sharedInstance].currentGroupIndex = indexPath.row;
    [self.navigationController pushViewController:ICEPhotoCollectionViewController.new animated:YES];
}

#pragma mark - Custom Deledate

#pragma mark - Event Response

- (void)onClickCancel:(UIBarButtonItem *)barCancel {
    [self dismissViewControllerAnimated:YES completion:^{
        // 将选中的照片从数组中移除
        [[ICEAssetManager sharedInstance].selectdPhotos removeAllObjects];
    }];
}

#pragma mark - Public Methods

#pragma mark - Private Methods

#pragma mark - Getters And Setters
- (UITableView *)getTableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    }
    return _tableView;
}
@end
