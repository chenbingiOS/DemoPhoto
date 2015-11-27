//
//  ICEAssetManager.h
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/12.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AssetsLibrary;
@class ALAsset;
@class ALAssetsGroup;

#define kNotificationUpdateSelected @"NotificationUpdateSelected"
#define kNotificationSendPhotos @"NotificationSendPhotos"

typedef NS_ENUM(NSInteger, ICEAssetManagerStyle) {
    ICEAssetManagerStyleThumbnail       = 1,
    ICEAssetManagerStyleAspectThumbnail = 2,
    ICEAssetManagerStyleScreenSize      = 3,
    ICEAssetManagerStyleFullResolution  = 4
};

@interface ICEAssetManager : NSObject
@property (nonatomic, assign, getter=isOriginal) BOOL hasOriginal;  ///<是否发送原图
@property (nonatomic, assign) NSInteger        maxSelected;         ///<可选最大数
@property (nonatomic, assign) NSInteger        currentGroupIndex;   ///<当前Group分组索引
@property (nonatomic, strong) NSMutableArray  *assetPhotos;         ///<当前Group图片数组
@property (nonatomic, strong) NSMutableArray  *selectdPhotos;       ///<选中对象数组

+ (instancetype)sharedInstance;

/** 获取分组个数 */
- (NSInteger)getGroupCount;
/** 获取选中照片分组 */
- (NSInteger)getSelectedPhotoCount;
/** 从某个分组中获取该分组的照片总数 */
- (NSInteger)getPhotoCountOfCurrentGroup;

/** 获取分组里面的照片列表 */
- (void)getGroupList:(void (^)(NSArray *))result;
/** 通过某个索引，获取对应 组 的 照片 集合*/
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result isOrder:(BOOL)order;

/** 添加一个选中图片 */
- (void)addObjectWithIndex:(NSInteger )index;
/** 移除一个选中图片 */
- (void)removeObjectWithIndex:(NSInteger )index;
/** 清除数据 */
- (void)clearData;

/** 通过索引获取分组 */
- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex;
/** 获取Group中的某张照片 */
- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType;
- (UIImage *)getImagePreviewAtIndex:(NSInteger)nIndex type:(NSInteger)nType;

- (NSInteger )markPreviewObjectWithIndex:(NSInteger )index selecte:(BOOL)selecte;
/** 该张照片是否被选中 */
- (BOOL)isSelectdPhotosWithIndex:(NSInteger )index;
- (BOOL)isSelectdPreviewWithIndex:(NSInteger )index;
/** 发送选中的照片 */
- (NSArray *)sendSelectedPhotos:(NSInteger )type;

- (NSInteger )currentGroupFirstIndex;

/** 获取选中照片的图片大小 */
- (NSString *)getSelectdPhotosSize;
@end

@interface ICEAssetPhoto : NSObject
@property (nonatomic, assign) CGFloat    KBBytes;
@property (nonatomic, assign) NSInteger  index;
@property (nonatomic, assign) BOOL       isSelected;
@property (nonatomic, strong) ALAsset   *asset;
@property (nonatomic, strong) NSString  *groupIndex;

- (instancetype)initWithGroup:(NSInteger )group index:(NSInteger )index asset:(ALAsset *)asset;

@end