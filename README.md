# XDLoopView
一个无限滚动的轮播图  ,(需要用到SDWebImage)

核心思路我已经在blog中给出：
http://blog.sina.com.cn/s/blog_14ecb54860102x6og.html

1. 导入头文件 添加代理

#import "XDLoopView.h"

@interface ViewController ()<XDLoopDelegate>

2. 创建轮播图

_source为图片资源（可以是远程网址，也可以是本地资源）

_loop = [[XDLoopView alloc]initWithFrame:CGRectMake(0,100,KWIDTH,KITEMHEIGHT)
                                bySourceArray:_source
                                     duration:4
                               defaultBgImage:nil];

_loop.delegate = self;

_loop.pageControlHidden = NO;//不隐藏页码（默认）

_loop.direction = XDLoop_Right_Left;//从右边往左边滚动（默认）

[self.view addSubview:_loop];


3. 轮播图点击事件代理

#pragma mark -- XDLoopViewDelegate

- (void)XDLoopViewDidSelectedAtIndex:(NSInteger)index inLoopView:(XDLoopView *)loopView {

    if (loopView == _loop) {

        NSLog(@"loop");

    }

    NSLog(@"点击了第：%ld 张图片",(long)index);
}


//加载失败或数组资源为空时默认背景图片的点击事件

- (void)XDLoopViewErrorSelectedinLoopView:(XDLoopView *)loopView {

//如果轮播图加载失败，在这个方法里进行重新加载

NSLog(@"当传入的数组为空数组时 的 默认图片的点击事件");

}


4. 轮播图刷新

// 当数据加载完毕或轮播图有变动时 可以用该方法对轮播图进行刷新

[_loop XDLoopRefreshWithSourceArray:_source];



