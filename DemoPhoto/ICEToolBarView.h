//
//  ICEToolBarView.h
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/18.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEToolBarView : UIView

- (instancetype)initWithWhiteColor;

- (instancetype)initWithBlackColor;

- (void)addPreviewTarget:(id)target action:(SEL)action;


@end
