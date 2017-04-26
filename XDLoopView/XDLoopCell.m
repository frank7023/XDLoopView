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

#define KWIDTH [[UIScreen mainScreen] bounds].size.width
#define KITEMHEIGHT 200

@interface XDLoopCell ()
@property (nonatomic, strong) SelectImageView *itemView;
@end

@implementation XDLoopCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatMainUI];
    }
    return self;
}

- (void)creatMainUI {
    _itemView = [[SelectImageView alloc]initWithFrame:self.bounds];
    _itemView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_itemView];
}

- (void)configCellWithSource:(NSString *)source atIndex:(NSInteger)idex {
    [_itemView sd_setImageWithURL:[NSURL URLWithString:source] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            _itemView.image = [UIImage imageNamed:source];
        }
    }];
    
    
    [_itemView tapGestureBlock:^(id obj) {
        [self.delegate xdLoopViewdidSelectedAtIndex:idex];
    }];
}
@end
