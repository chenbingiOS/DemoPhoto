//
//  ICEPhotoCollectionViewCell.h
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/18.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEPhotoCollectionViewCell : UICollectionViewCell

+ (NSString *)cellReuseIdentifier;

- (void)setContentWithIndexPath:(NSIndexPath *)indexPath;
@end
