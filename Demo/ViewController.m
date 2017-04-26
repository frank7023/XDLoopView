//
//  ViewController.m
//  Demo
//
//  Created by 谢兴达 on 2017/4/26.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "ViewController.h"
#import "XDLoopView.h"

#define KWIDTH [[UIScreen mainScreen] bounds].size.width
#define KITEMHEIGHT 200

@interface ViewController ()<XDLoopDelegate>

@property (nonatomic, strong) NSArray *source;
@property (nonatomic, strong) XDLoopView *loop;

@property (nonatomic, strong) XDLoopView *loop2;


@property (nonatomic, copy)void (^block)(void);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _source = @[@"http://scimg.jb51.net/allimg/160815/103-160Q509544OC.jpg",
                @"http://img.taopic.com/uploads/allimg/130711/318756-130G1222R317.jpg",
                @"test2.jpeg",
                @"test1.jpeg",
                @"http://www.taopic.com/uploads/allimg/120421/107063-12042114025737.jpg"];
    [self XDLoopUI];
}


- (void)XDLoopUI {
    //1.
    /****************************默认从右边 ——> 左边滚动********************************/
    _loop = [[XDLoopView alloc]initWithFrame:CGRectMake(0,100,KWIDTH,KITEMHEIGHT)
                               bySourceArray:_source
                                    duration:4
                              defaultBgImage:nil];
    _loop.delegate = self;
    _loop.pageControlHidden = NO;
    [self.view addSubview:_loop];
    /*
     如果开始时没有数据，可以在数据请求完毕时调用下面的方法，刷新轮播图
     [_loop XDLoopRefreshWithSourceArray:_source];
     */
    /****************************默认从右边 ——> 左边滚动********************************/
    
    
    
    //2.
    /****************************从左边 ——> 右边滚动********************************/
    _loop2 = [[XDLoopView alloc]initWithFrame:CGRectMake(0, 100+KITEMHEIGHT + 50, KWIDTH, KITEMHEIGHT)
                                bySourceArray:_source
                                     duration:4
                               defaultBgImage:nil];
    _loop2.delegate = self;
    _loop2.direction = XDLoop_Left_Right;
    [self.view addSubview:_loop2];
    /*
     如果开始时没有数据，可以在数据请求完毕时调用下面的方法，刷新轮播图
     [_loop2 XDLoopRefreshWithSourceArray:_source];
     */
    /****************************从左边 ——> 右边滚动********************************/
    
}

#pragma mark -- XDLoopViewDelegate
- (void)XDLoopViewDidSelectedAtIndex:(NSInteger)index inLoopView:(XDLoopView *)loopView {
    if (loopView == _loop2) {
        NSLog(@"loop2");
    }
    NSLog(@"点击了第：%ld 张图片",(long)index);
}

- (void)XDLoopViewErrorSelectedinLoopView:(XDLoopView *)loopView {
    //如果轮播图加载失败，在这个方法里进行重新加载
    NSLog(@"当传入的数组为空数组时 的 默认图片的点击事件");
}

@end
