//
//  XDLoopCell.m
//  XDLoopView
//
//  Created by 谢兴达 on 2017/4/26.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import "XDLoopCell.h"
#import "SelectImageView.h"
#import "UIImageView+WebCache.h"

@interface XDLoopCell ()
@property (nonatomic, strong) SelectImageView *itemView;

@end

@implementation XDLoopCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatMainUI];
        self.contentView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)creatMainUI {
    
    //实现模糊效果
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    //毛玻璃视图
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    
    visualEffectView.frame = self.bounds;
    
    visualEffectView.alpha = 0.9;
    
    [self.contentView addSubview:visualEffectView];
    
    _itemView = [[SelectImageView alloc]initWithFrame:self.bounds];
    _itemView.backgroundColor = [UIColor clearColor];
    _itemView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_itemView];
}

- (void)configCellWithSource:(NSString *)source atItem:(NSInteger)item {
    __weak typeof(self) weakSelf = self;
    [_itemView sd_setImageWithURL:[NSURL URLWithString:source] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            weakSelf.itemView.image = [UIImage imageNamed:source];
        }
        weakSelf.contentView.backgroundColor = [UIColor colorWithPatternImage:weakSelf.itemView.image];
    }];
    
    [_itemView tapGestureBlock:^(id obj) {
        [weakSelf.delegate xdLoopViewdidSelectedAtItem:item];
    }];
}
@end
