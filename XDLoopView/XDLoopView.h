//
//  XDLoopView.h
//  轮播图
//  作者：谢兴达（XD）
//  Created by 谢兴达 on 2017/4/25.
//  Copyright © 2017年 谢兴达. All rights reserved.
//  github:https://github.com/Xiexingda/XDLoopView.git

#import <UIKit/UIKit.h>

@class XDLoopView;

typedef NS_ENUM(NSInteger, XDLoopScrollDirection) {
    XDLoop_Right_Left,  //默认从右 往 左 滚动
    XDLoop_Left_Right   //从 左 往 右 滚动
};

@protocol XDLoopDelegate <NSObject>
@optional
/**
 点击轮播图片是的相应

 @param item 所点击的图片的index
 */
- (void)XDLoopViewDidSelectedAtItem:(NSInteger)item inLoopView:(XDLoopView *)loopView;

/**
 当加载失败或没有资源时 默认背景图片的点击事件
 */
- (void)XDLoopViewErrorSelectedinLoopView:(XDLoopView *)loopView;
@end

@interface XDLoopView : UIView <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic, weak) id<XDLoopDelegate> delegate;
//隐藏 页码
@property (nonatomic, assign) BOOL pageControlHidden;
//数组资源
@property (nonatomic, strong) NSArray *sourcesArray;
//滚动方向
@property (nonatomic, assign) XDLoopScrollDirection direction;
//是否自动滚动
@property (nonatomic, assign) BOOL isAutoRolling;

/**
 轮播图

 @param frame 轮播图位置大小
 @param sources 轮播图资源（本地和远程皆可）
 @param duration 轮播间隔（最小为1 秒）
 @param imageName 当没有数据时的默认背景图片
 @return 轮播图
 */
- (instancetype)initWithFrame:(CGRect)frame bySourceArray:(NSArray *)sources duration:(CGFloat)duration defaultBgImage:(NSString *)imageName;

/**
 刷新轮播图

 @param sources 新的轮播图资源数组
 */
- (void)XDLoopRefreshWithSourceArray:(NSArray *)sources;
@end
