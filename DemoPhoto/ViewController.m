//
//  ViewController.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/11.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ViewController.h"
#import "ICEPhotoActionSheet.h"

@interface ViewController ()
@property (nonatomic, strong) ICEPhotoActionSheet *sheet;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sheet = [[ICEPhotoActionSheet alloc] initWithMaxSelected:9 weakSuper:self];
//    [self.view addSubview:self.sheet];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.sheet showPhotoActionSheet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
