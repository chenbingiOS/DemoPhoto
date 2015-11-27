//
//  ICEThumbnailCheckCell.h
//  DemoPhoto
//
//  Created by ttouch on 15/11/23.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEThumbnailCheckCell : UICollectionViewCell

+ (NSString *)cellReuseIdentifier;

- (void)setContentWithIndexPath:(NSIndexPath *)indexPath;

@end
