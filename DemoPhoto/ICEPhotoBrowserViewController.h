//
//  ICEPhotoBrowserViewController.h
//  DemoPhoto
//
//  Created by ttouch on 15/11/19.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ICEPhotoBrowserViewController;

@protocol ICEPhotoBrowserDelegate < NSObject >
/** 显示第几张图 */
- (UIImage *)displayImageWithIndex:(NSInteger)index fromPhotoBrowser:(ICEPhotoBrowserViewController *)browser;
/** 照片数量 */
- (NSInteger)numberOfPhotosFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser;
/** 跳到选中的显示图片 */
- (NSInteger)jumpIndexFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser;

- (BOOL)isSelectedPhotosWithIndex:(NSInteger)index fromPhotoBrowser:(ICEPhotoBrowserViewController *)browser;

- (BOOL)isCheckMaxSelectedFromPhotoBrowser:(ICEPhotoBrowserViewController *)browser;

- (void)displayImageWithIndex:(NSUInteger)index selectedChanged:(BOOL)selected;

@end

@interface ICEPhotoBrowserViewController : UIViewController

@property (nonatomic, weak) id<ICEPhotoBrowserDelegate> delegate;

@end
