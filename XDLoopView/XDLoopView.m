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

#define LOOPWIDTH self.bounds.size.width
#define LOOPHEIGHT self.bounds.size.height

#define DURATION 5  //滚动间隔时间

@interface XDLoopView ()<XDLoopCellDelegate> {
    CGFloat _duration;
}
@property (nonatomic, strong) UICollectionViewFlowLayout *loopLayout;
@property (nonatomic, strong) UICollectionView *loopView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) LoopViewStatus currenStatus;
@property (nonatomic, strong) NSArray *sourcesArray;
@property (nonatomic, strong) SelectImageView *defaultBg;

@end

@implementation XDLoopView

- (void)setPageControlHidden:(BOOL)pageControlHidden {
    _pageControlHidden = pageControlHidden;
    self.pageControl.hidden = pageControlHidden;
}

- (void)setIsAutoRolling:(BOOL)isAutoRolling {
    _isAutoRolling = isAutoRolling;
    if (_timer&&!_isAutoRolling) {
        [self endTimer];
    } else {
        [self endTimer];
        [self startTimer];
    }
}

- (instancetype)initWithFrame:(CGRect)frame bySourceArray:(NSArray *)sources duration:(CGFloat)duration defaultBgImage:(NSString *)imageName{
    self = [super initWithFrame:frame];
    if (self) {
        _isAutoRolling = YES;
        _pageControlHidden = NO;
        _direction = XDLoop_Right_Left;
        [self creatDefaultBGWithSource:sources duration:duration andDefaultImage:imageName];
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
    __weak typeof(self) weakSelf = self;
    _duration = duration;
    _defaultBg = [[SelectImageView alloc]initWithFrame:self.bounds];
    _defaultBg.backgroundColor = [UIColor lightGrayColor];
    _defaultBg.image = [UIImage imageNamed:imageName];
    _defaultBg.hidden = sources.count > 0;
    [self addSubview:_defaultBg];
    [_defaultBg tapGestureBlock:^(id obj) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(XDLoopViewErrorSelectedinLoopView:)]) {
            [strongSelf.delegate XDLoopViewErrorSelectedinLoopView:strongSelf];
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
    _loopLayout.itemSize=CGSizeMake(LOOPWIDTH, LOOPHEIGHT);  //设置每个单元格的大小
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
    if (!_pageControl&&!_pageControlHidden) {
        _pageControl = [[UIPageControl alloc] initWithFrame:
                        CGRectMake(0,
                                   LOOPHEIGHT - 50,
                                   LOOPWIDTH,
                                   50)];
        _pageControl.currentPage = 0;
    }
    
    _pageControl.numberOfPages = sources.count;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.hidden = self.pageControlHidden;
    [self insertSubview:_pageControl aboveSubview:_loopView];
    
    [self startTimer];
}

/**
 创建并开启计时器
 */
- (void)startTimer {
    __weak typeof(self) weakSelf = self;
    if (!_timer && _isAutoRolling) {
        _duration = _duration < 1 ? 1 : _duration;
        _timer = dispatch_source_create(&_dispatch_source_type_timer, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, _duration*NSEC_PER_SEC), _duration*NSEC_PER_SEC, 0*NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(_timer, ^{
            CGFloat currentOffsetX = weakSelf.loopView.contentOffset.x;
            
            if (weakSelf.direction == XDLoop_Right_Left) {
                currentOffsetX += LOOPWIDTH;
                
            } else if (weakSelf.direction == XDLoop_Left_Right) {
                currentOffsetX -= LOOPWIDTH;
            }
            
            NSIndexPath *indexPath = [weakSelf.loopView indexPathForItemAtPoint:CGPointMake(currentOffsetX, 0)];
            
            //滚动到下一张
            [weakSelf.loopView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        });
        
        dispatch_resume(_timer);
    }
}

//结束计时器
- (void)endTimer {
    if (!_timer) {
        return;
    }
    dispatch_source_cancel(_timer);
    _timer = nil;
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
    [cell configCellWithSource:source atItem: indexPath.row];
    return cell;
}

/**
 xdloopcell 的代理

 @param item 所点击的item的索引
 */
- (void)xdLoopViewdidSelectedAtItem:(NSInteger)item {
    if ([self.delegate respondsToSelector:@selector(XDLoopViewDidSelectedAtItem:inLoopView:)]) {
        [self.delegate XDLoopViewDidSelectedAtItem:item - 1 inLoopView:self];
    }
}


/*
 拖拽状态下的 五 种状态 要考虑全面
 */

//状态1，开始滚动之前
//开始拖拽时改为拖拽状态，计时器停止
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currenStatus = LOOP_LOOPDRAG;
    [self endTimer];
}

//状态2，滚动之时
/*
 只要滚动就会调用改代理，为了避免重复计算，我们只在手动拖动时去计算每一个位置
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_currenStatus == LOOP_LOOPDRAG) {
        [self mainMethod];
    }
}

//状态3，将要滚动减速之前
/*
 如果是在拖拽状态时 开始减速时调用
 实测只有在手动拉动时才会调用该方法（scrollToItemAtIndexPath方法不会触发此代理）
 */
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self mainMethod];
}

//状态4，滚动减速为0
/*
 如果是在拖拽状态时 减速结束后调用
 实测只有在手动拉动时才会调用该方法（scrollToItemAtIndexPath方法不会触发此代理）
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self mainMethod];
}

//状态5，拖动结束
/*
 当拖拽技术时调用，此时状态改为自定模式，并开启计时器
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _currenStatus = LOOP_LOOPAUTO;
    [self startTimer];
}


/*
 结束滚动时调用，由scrollToItemAtIndexPath方法触发
 实测手动拉动时不会触发该方法
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self mainMethod];
}

/**
 核心无限循环算法
 
 该算法看似很简单，但已经诠释了循环的全部细节
 原理就不在这里详述了
 如果想不明白的话可以去看我的博客：http://blog.sina.com.cn/s/blog_14ecb54860102x6og.html
 */
- (void)mainMethod {
    
    //循环处理（核心）
    if (_loopView.contentOffset.x <= 0) {
        _loopView.contentOffset = CGPointMake(LOOPWIDTH*self.sourcesArray.count, 0);
        
    } else if (_loopView.contentOffset.x >= (self.sourcesArray.count + 1)*LOOPWIDTH) {
        _loopView.contentOffset = CGPointMake(LOOPWIDTH, 0);
        
    }
    
    /*
     页码显示处理，当滑动到item的一半时切换页码 
     由于是从第二个位置开始，所以要想页码正确显示需要 -1（即：第2个位置页码为1，第三个位置页码为2依次类推）
    */
    int currentPage = (int)((_loopView.contentOffset.x + LOOPWIDTH/2)/LOOPWIDTH) - 1;
    
    /*
     注意* 一定要做 <0 和 >self.sourcesArray.count - 1(最大页码) 的判断，
          否则自动滚动时是没有问题的，但在拖拽着滚动到最左边或最右边时页码不会替换
     
     原因：
          自动滚动时调用该方法（mainMethod）的时机是滚动结束后 此时条件已经满 足循环处理，
          offset被限定在了 LOOPWIDTH ~ LOOPWIDTH*self.sourcesArray.count 之间 
          所以currentPage不会出现小于0 和大于self.sourcesArray.count - 1 的数
     
          拖拽滚动的时调用该方法（mainMethod）的时机是滚动进行时调用，
          这个时候offset 如果在 （0 ~ LOOPWIDTH） 或 （(self.sourcesArray.count)*LOOPWIDTH ~ (self.sourcesArray.count + 1)*LOOPWIDTH） 之间
          这个时候还没有出发循环处理 currentPage就会出现 < 0 和 >self.sourcesArray.count - 1 的情况 ，如果没有做判断，那么这个时候页码就会出现问题
     */
    if (currentPage < 0) {
        _pageControl.currentPage = self.sourcesArray.count;
        
    } else if (currentPage > self.sourcesArray.count-1) {
        _pageControl.currentPage = 0;
        
    } else {
        _pageControl.currentPage = currentPage;
    }
}

/**
 刷新轮播图

 @param sources 轮播图新资源数组
 */
- (void)XDLoopRefreshWithSourceArray:(NSArray *)sources {
    if (sources.count == 0) {
        return;
    }
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
        
    //开始刷新
    [_loopView reloadData];
    
    //更正当前index
    [self mainMethod];
}

/**
 当不需要页码和计时器时的处理
 */
- (void)noPageAndTimerHandle {
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    [self endTimer];
}

@end
