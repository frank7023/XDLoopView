//
//  XDLoopView.m
//  XDLoopView
//  
//  Created by 谢兴达 on 2017/4/25.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "XDLoopView.h"
#import "XDLoopCell.h"
#import "SelectImageView.h"

typedef NS_ENUM(NSInteger, LoopViewStatus) {
    LOOP_LOOPAUTO,
    LOOP_LOOPDRAG
};

#define KWIDTH self.bounds.size.width
#define KITEMHEIGHT self.bounds.size.height

#define DURATION 5  //滚动间隔时间

@interface XDLoopView ()<XDLoopCellDelegate> {
    CGFloat _duration;
}
@property (nonatomic, strong) UICollectionViewFlowLayout *loopLayout;
@property (nonatomic, strong) UICollectionView *loopView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) LoopViewStatus currenStatus;

@property (nonatomic, strong) SelectImageView *defaultBg;

@end

@implementation XDLoopView

- (instancetype)initWithFrame:(CGRect)frame bySourceArray:(NSArray *)sources duration:(CGFloat)duration defaultBgImage:(NSString *)imageName{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatDefaultBGWithSource:sources duration:(CGFloat)duration andDefaultImage:imageName];
    }
    
    return self;
}

/**
 创建默认背景图片

 @param sources 图片源数组
 */
- (void)creatDefaultBGWithSource:(NSArray *)sources duration:(CGFloat)duration andDefaultImage:(NSString *)imageName {
    if (_defaultBg) {
        return;
    }
    _duration = duration;
    _defaultBg = [[SelectImageView alloc]initWithFrame:self.bounds];
    _defaultBg.backgroundColor = [UIColor lightGrayColor];
    _defaultBg.image = [UIImage imageNamed:imageName];
    _defaultBg.hidden = sources.count > 0;
    [self addSubview:_defaultBg];
    [_defaultBg tapGestureBlock:^(id obj) {
        if ([self.delegate respondsToSelector:@selector(XDLoopViewErrorSelectedinLoopView:)]) {
            [self.delegate XDLoopViewErrorSelectedinLoopView:self];
        }
    }];
    
    [self MainUIWithSourceArray:sources];
}

/**
 创建轮播图
 资源数组为0时直接返回
 @param sources 图片资源数组
 */
- (void)MainUIWithSourceArray:(NSArray *)sources {
    
    /**如果资源数组为零就直接返回，不进行创建loopview**/
    if (sources.count == 0) {
        return;
    }
    //只实现一次loopview 和 looplayout
    if (_loopView||_loopLayout) {
        return;
    }
    _sourcesArray = [NSArray arrayWithArray:sources];
    
    _loopLayout = [[UICollectionViewFlowLayout alloc]init];
    _loopLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _loopLayout.minimumLineSpacing = 0; //设置每一行的间距
    _loopLayout.minimumInteritemSpacing = 0;
    _loopLayout.itemSize=CGSizeMake(KWIDTH, KITEMHEIGHT);  //设置每个单元格的大小
    _loopLayout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    _loopView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:_loopLayout];
    _loopView.delegate = self;
    _loopView.dataSource = self;
    _loopView.pagingEnabled = YES;
    _loopView.clipsToBounds = YES;
    _loopView.backgroundColor = [UIColor lightGrayColor];
    _loopView.showsHorizontalScrollIndicator = NO;
    _loopView.showsVerticalScrollIndicator = NO;
    
    /**让loopview的初始状态从第二个item开始**/
    [_loopView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self insertSubview:_loopView aboveSubview:_defaultBg];
    
    [_loopView registerClass:[XDLoopCell class] forCellWithReuseIdentifier:@"XDLoopCell"];
    _currenStatus = LOOP_LOOPAUTO;
    
    
    if (sources.count > 1) {
        [self creatPageControllWithSource:sources];
        _loopView.scrollEnabled = YES;
        
    } else {
        _loopView.scrollEnabled = NO;
    }
    
}

/**
 创建页码标识

 @param sources 资源数组
 */
- (void)creatPageControllWithSource:(NSArray *)sources {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:
                        CGRectMake(0,
                                   KITEMHEIGHT - 50,
                                   KWIDTH,
                                   50)];
    }
    
    _pageControl.numberOfPages = sources.count;
    _pageControl.currentPage = 0;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.hidden = self.pageControlHidden;
    [self insertSubview:_pageControl aboveSubview:_loopView];
    
    [self startTimer];
}

/**
 创建并开启计时器
 */
- (void)startTimer {
    if (!_timer) {
        _duration = _duration < 1 ? 1 : _duration;
        _timer = [NSTimer scheduledTimerWithTimeInterval:_duration
                                                  target:self
                                                selector:@selector(timerCall:)
                                                userInfo:nil
                                                 repeats:YES];
    }
}

- (void)timerCall:(NSTimer *)timer {
    CGFloat currentOffsetX = _loopView.contentOffset.x;
    
    if (self.direction == XDLoop_Right_Left) {
        currentOffsetX += KWIDTH;
        
    } else if (self.direction == XDLoop_Left_Right) {
        currentOffsetX -= KWIDTH;
    }
    
    NSIndexPath *indexPath = [_loopView indexPathForItemAtPoint:CGPointMake(currentOffsetX, 0)];
    
    //滚动到下一张
    [_loopView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourcesArray.count + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XDLoopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"XDLoopCell" forIndexPath:indexPath];
    cell.delegate = self;
    NSString *source = nil;
    if (indexPath.row == 0) {
        source = _sourcesArray[_sourcesArray.count - 1];
    } else if (indexPath.row == _sourcesArray.count + 1) {
        source = _sourcesArray[0];
    } else {
        source = _sourcesArray[indexPath.row - 1];
    }
    [cell configCellWithSource:source atIndex:indexPath.row];
    return cell;
}

/**
 xdloopcell 的代理

 @param index 所点击的item的索引
 */
- (void)xdLoopViewdidSelectedAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(XDLoopViewDidSelectedAtIndex:inLoopView:)]) {
        [self.delegate XDLoopViewDidSelectedAtIndex:index - 1 inLoopView:self];
    }
}

//开始拖拽时改为拖拽状态，计时器停止
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currenStatus = LOOP_LOOPDRAG;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

/*
 如果是在拖拽状态时 滚动
 实测只有在手动拉动时才会调用该方法（scrollToItemAtIndexPath方法不会触发此代理）
 保险起见需要加一层判断
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_currenStatus == LOOP_LOOPDRAG) {
        [self mainMethod];
    }
}

/*
 如果是在拖拽状态时 开始减速时调用
 实测只有在手动拉动时才会调用该方法（scrollToItemAtIndexPath方法不会触发此代理）
 保险起见需要加一层判断
 */
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (_currenStatus == LOOP_LOOPDRAG) {
        [self mainMethod];
    }
}

/*
 如果是在拖拽状态时 减速结束后调用，此时把状态设置为自动 并开启计时器
 实测只有在手动拉动时才会调用该方法（scrollToItemAtIndexPath方法不会触发此代理）
 保险起见需要加一层判断
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_currenStatus == LOOP_LOOPDRAG) {
        _currenStatus = LOOP_LOOPAUTO;
        [self mainMethod];
        [self startTimer];
    }
}

/*
 结束滚动时调用，由scrollToItemAtIndexPath方法触发
 实测手动拉动时不会触发该方法，保险起见需要加一层判断
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_currenStatus == LOOP_LOOPAUTO) {
        [self mainMethod];
    }
}

/**
 核心无限循环算法
 
 该算法看似很简单，但已经诠释了循环的全部细节
 原理就不在这里详述了
 如果想不明白的话可以去看我的博客：http://blog.sina.com.cn/s/blog_14ecb54860102x6og.html
 */
- (void)mainMethod {
    
    if (_loopView.contentOffset.x <= KWIDTH/2) {
        _pageControl.currentPage = self.sourcesArray.count;
        _loopView.contentOffset = CGPointMake(KWIDTH*self.sourcesArray.count, 0);
        
    } else if (_loopView.contentOffset.x > (self.sourcesArray.count)*KWIDTH + KWIDTH/2) {
        _pageControl.currentPage = 0;
        _loopView.contentOffset = CGPointMake(KWIDTH, 0);
        
    } else {
        _pageControl.currentPage = (int)(_loopView.contentOffset.x/KWIDTH) - 1;
    }
}

/**
 刷新轮播图

 @param sources 轮播图新资源数组
 */
- (void)XDLoopRefreshWithSourceArray:(NSArray *)sources {
    /**根据资源有无决定是否显示默认背景**/
    _defaultBg.hidden = sources.count > 0;
    
    /**如果此时还没有创建——loopview，就直接创建并返回**/
    if (!_loopView||!_loopLayout) {
        [self MainUIWithSourceArray:sources];
        return;
    }
    
    /**如果这个时候loopview已经创建了，那就需要走下面的逻辑**/
    
    if (_loopView) {
        /**根据资源有无决定是否隐藏_loopView,用以显示出默认背景**/
        _loopView.hidden = sources.count == 0;
    }
    
    //资源为0 隐藏掉页码 关掉计时器 后直接返回
    if (sources.count == 0) {
        [self noPageAndTimerHandle];
        return;
       
        //只有一张资源时 不需要页码 和 计时器 也不需要滚动
    } else if (sources.count == 1) {
        [self noPageAndTimerHandle];
        _loopView.scrollEnabled = NO;
        
        //资源多于一张时 需要显示 页码 和 计时器 并且需要能够滚动
    } else if (sources.count > 1) {
        [self creatPageControllWithSource:sources];
        _loopView.scrollEnabled = YES;
    }
    
    //把刷新资源数组 赋值 给资源数组
    _sourcesArray = [NSArray arrayWithArray:sources];
    
    //每次更新资源后让轮播图恢复最初状态
    [_loopView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    //开始刷新
    [_loopView reloadData];
}

/**
 当不需要页码和计时器时的处理
 */
- (void)noPageAndTimerHandle {
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
