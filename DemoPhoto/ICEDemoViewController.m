//
//  ICEDemoViewController.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/11.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEDemoViewController.h"
#import "ICEPhotoActionSheet.h"

@interface ICEDemoViewController () <UITableViewDataSource, UITableViewDelegate, ICEPhotoActionSheetDelegate>
@property (nonatomic, strong, getter=getTableView) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imgAry;
@end

@implementation ICEDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openSheet)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - life cycle

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imgAry.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
    imgView.image = self.imgAry[indexPath.row];
    [cell addSubview:imgView];
    return cell;
}

#pragma mark - Coustom Delegate 
- (void)actionSheetDidFinished:(NSArray *)ary {
    self.imgAry = [NSMutableArray array];
    self.imgAry = [ary copy];
    [self.tableView reloadData];
}

#pragma mark - Event Response

- (void)openSheet {
    ICEPhotoActionSheet *sheet = [[ICEPhotoActionSheet alloc] initWithMaxSelected:9 weakSuper:self];
    sheet.delegate = self;
    [sheet showPhotoActionSheet];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

#pragma mark - Public Methods

#pragma mark - Private Methods

#pragma mark - Getters And Setters

- (UITableView *)getTableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
