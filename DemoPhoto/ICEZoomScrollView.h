//
//  ICEZoomScrollView.h
//  DemoPhoto
//
//  Created by ttouch on 15/11/20.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEZoomScrollView : UIScrollView

- (void)prepareForReuse;

- (void)displayImage:(UIImage *)img;

- (void)addImageTarget:(id)target action:(SEL)action;
@end
