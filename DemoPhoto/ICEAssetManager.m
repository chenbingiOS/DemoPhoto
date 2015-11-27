//
//  ICEAssetManager.m
//  DemoPhoto
//
//  Created by 陈冰 on 15/11/12.
//  Copyright © 2015年 iCE. All rights reserved.
//

#import "ICEAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ICEAssetManager()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray  *assetGroups;
@property (nonatomic, strong) ALAsset         *selectdAsset;
@end
@implementation ICEAssetManager

+ (instancetype)sharedInstance {
    static ICEAssetManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ICEAssetManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _selectdPhotos = [[NSMutableArray alloc] init];
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        [_assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:nil];
    }
    return self;
}

/** 获取分组列表 */
- (void)getGroupList:(void (^)(NSArray *))result {
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if (group == nil){
            result(_assetGroups);
            return;
        }
        [_assetGroups insertObject:group atIndex:0];
    };
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error)
    {
        NSLog(@"Error : %@", [error description]);
    };
    
    _assetGroups = [[NSMutableArray alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
}

/** 获取对应 组 的 照片集合*/
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result isOrder:(BOOL)order{
    _assetPhotos = [[NSMutableArray alloc] init];
    [alGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    [alGroup enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
        if(alPhoto == nil) {
            result(_assetPhotos);
            return;
        }
        
#warning 有个顺序的问题  无法和QQ一模一样
//        if (order) {
//            [_assetPhotos addObject:alPhoto]; // 正序 和系统相册相同
//        } else {
            [_assetPhotos insertObject:alPhoto atIndex:0]; // 逆序
//        }
    }];
}

/** 通过某个索引，获取对应 组 的 照片 集合*/
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result isOrder:(BOOL)order{
    [self getPhotoListOfGroup:_assetGroups[nGroupIndex] result:^(NSArray *aResult) {
        result(_assetPhotos);
    } isOrder:order];
}

/** 通过某个索引，获取对应 组 的 照片 集合*/
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error{
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
                if(alPhoto == nil){
                    result(_assetPhotos);
                    return;
                }
                [_assetPhotos addObject:alPhoto];
            }];
        }
    };
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *err)
    {
        NSLog(@"Error : %@", [err description]);
        error(err);
    };
    _assetPhotos = [[NSMutableArray alloc] init];
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
}

/** 获取 组 的数目 */
- (NSInteger)getGroupCount{
    return _assetGroups.count;
}

/** 获取 当前分组的 照片个数 */
- (NSInteger)getPhotoCountOfCurrentGroup{
    return _assetPhotos.count;
}

/** 获取 选中的分组 */
- (NSInteger)getSelectedPhotoCount{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == %d", YES];
    NSArray *results = [_selectdPhotos filteredArrayUsingPredicate:predicate];
    return results.count;
}

/** 清除数据 */
- (void)clearData{
    [_selectdPhotos removeAllObjects];
    [_assetGroups removeAllObjects];
    [_assetPhotos removeAllObjects];
    
    _selectdPhotos = nil;
    
    _assetGroups   = nil;
    _assetPhotos   = nil;
}

#pragma mark - utils
/** 获取选中照片的图片大小 */
- (NSString *)getSelectdPhotosSize {
    CGFloat numKBBytes = 0.0f;
    for (ICEAssetPhoto *model in _selectdPhotos) {
        numKBBytes += model.KBBytes;
    }
    if (numKBBytes > 1024) {
        NSInteger perMBBytes = 1024;
        CGFloat MBBytes = (CGFloat)numKBBytes/perMBBytes;
        return [NSString stringWithFormat:@"%.1fM",MBBytes];
    } else {
        return [NSString stringWithFormat:@"%.0fK",numKBBytes];
    }
}

- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType{
    CGImageRef iRef = nil;
    if (nType == ICEAssetManagerStyleThumbnail)
    {
        iRef = [asset thumbnail];
    }
    else if (nType == ICEAssetManagerStyleAspectThumbnail)
    {
        iRef = [asset aspectRatioThumbnail];
    }
    else if (nType == ICEAssetManagerStyleScreenSize)
    {
        iRef = [asset.defaultRepresentation fullScreenImage];
    }
    else if (nType == ICEAssetManagerStyleFullResolution)
    {
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        CGImageRef fullResImage = [assetRepresentation fullResolutionImage];
        NSString *adjustment = [[assetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
        if (adjustment == nil || [adjustment isKindOfClass:[NSNull class]]) {
            iRef = [assetRepresentation fullResolutionImage];
            UIImage *iImage = [UIImage imageWithCGImage:iRef
                                                  scale:1.0
                                            orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            CGImageRelease(iRef);
            return iImage;
        } else {
            NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *image = [CIImage imageWithCGImage:fullResImage];
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            } else {
                for (CIFilter *filter in filterArray) {
                    [filter setValue:image forKey:kCIInputImageKey];
                    image = [filter outputImage];
                }
            }
            
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgimage = [context createCGImage:image fromRect:[image extent]];
            UIImage *iImage = [UIImage imageWithCGImage:cgimage
                                                  scale:[assetRepresentation scale]
                                            orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
//            CGImageRelease(cgimage);
            return iImage;
        }
    }
    return [UIImage imageWithCGImage:iRef];
}

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType {
    return [self getImageFromAsset:(ALAsset *)_assetPhotos[nIndex] type:nType];
}

- (UIImage *)getImagePreviewAtIndex:(NSInteger)nIndex type:(NSInteger)nType {
    ICEAssetPhoto *obj = _selectdPhotos[nIndex];
    return [self getImageFromAsset:(ALAsset *)obj.asset type:nType];
}

- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex {
    return _assetPhotos[nIndex];
}

- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex {
    return _assetGroups[nIndex];
}

- (NSArray *)sendSelectedPhotos:(NSInteger )type {
    NSMutableArray *sendArray = [NSMutableArray array];
    for (ICEAssetPhoto *model in _selectdPhotos) {
        UIImage *image = [self getImageFromAsset:model.asset type:type];
        [sendArray addObject:image];
    }
    [_selectdPhotos removeAllObjects];
    return sendArray;
}

/** 添加一个选中图片 */
- (void)addObjectWithIndex:(NSInteger )index {
    ICEAssetPhoto *model = [[ICEAssetPhoto alloc] initWithGroup:_currentGroupIndex index:index asset:_assetPhotos[index]];
    [_selectdPhotos addObject:model];
    
    // 通知工具栏可以使用
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateSelected object:nil];
}
/** 移除一个选中图片 */
- (void)removeObjectWithIndex:(NSInteger )index {
    NSString *groupIndex = [NSString stringWithFormat:@"%ld-%ld",(long)_currentGroupIndex,(long)index];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupIndex == %@", groupIndex];
    NSArray *results = [_selectdPhotos filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        ICEAssetPhoto *model = results[0];
        [_selectdPhotos removeObject:model];
        
        // 通知工具栏可以使用
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateSelected object:nil];
    }
}

- (void)markFilterPreviewObject {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected == %d", YES];
    NSArray *results = [_selectdPhotos filteredArrayUsingPredicate:predicate];
    
    [_selectdPhotos removeAllObjects];
    [_selectdPhotos addObjectsFromArray:results];
}

- (NSInteger )markPreviewObjectWithIndex:(NSInteger )index selecte:(BOOL)selecte{
    
    ICEAssetPhoto *model = _selectdPhotos[index];
    model.isSelected = selecte;
    
    // 通知工具栏可以使用
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateSelected object:nil];
    
    return model.index;
}

- (BOOL)isSelectdPreviewWithIndex:(NSInteger )index{
    ICEAssetPhoto *model = _selectdPhotos[index];
    return model.isSelected;
}

/** 该张照片是否被选中 */
- (BOOL)isSelectdPhotosWithIndex:(NSInteger )index{
    NSString *groupIndex = [NSString stringWithFormat:@"%ld-%ld",(long)_currentGroupIndex,(long)index];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupIndex == %@", groupIndex];
    NSArray *results = [_selectdPhotos filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        ICEAssetPhoto *model = results[0];
        return model.isSelected;
    }
    return NO;
}

/** 当前分组中第一个对象 */
- (NSInteger )currentGroupFirstIndex{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group == %ld", (long)_currentGroupIndex];
    NSArray *results = [_selectdPhotos filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        ICEAssetPhoto *model = results[0];
        return model.index;
    }
    return 0;
}

@end


/****************************************************
 *
 *  Model
 *
 ****************************************************/
@interface ICEAssetPhoto()

@property (nonatomic, assign) NSInteger group;

@end

@implementation ICEAssetPhoto

- (instancetype)initWithGroup:(NSInteger )group index:(NSInteger )index asset:(ALAsset *)asset {
    if (self = [super init]) {
        _index = index;
        _group = group;
        _asset = asset;
        _isSelected = YES;
        _groupIndex = [NSString stringWithFormat:@"%ld-%ld",(long)group,(long)index];
        _KBBytes = [self abbreviation:asset];
    }
    return self;
}

- (CGFloat)abbreviation:(ALAsset *)asset {
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSInteger  perKBBytes = 1024;
    CGFloat fileMB = (CGFloat)([representation size])/perKBBytes;
//    NSLog(@"size of asset in bytes: %f", fileMB);
    return fileMB;
}
@end
