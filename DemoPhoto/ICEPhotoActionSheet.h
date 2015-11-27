//
//  ICEPhotoActionSheet.h
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/11.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ICEPhotoActionSheet;
@protocol ICEPhotoActionSheetDelegate <NSObject>

- (void)actionSheetDidFinished:(NSArray *)ary;

@end

@interface ICEPhotoActionSheet : UIView

@property (nonatomic, weak) id<ICEPhotoActionSheetDelegate> delegate;

- (instancetype)initWithMaxSelected:(NSInteger )maxSelected weakSuper:(id)weakSuper;

- (void)showPhotoActionSheet;

@end
