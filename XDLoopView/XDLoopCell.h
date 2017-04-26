//
//  XDLoopCell.h
//  XDLoopView
//
//  Created by 谢兴达 on 2017/4/26.
//  Copyright © 2017年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XDLoopCellDelegate <NSObject>

- (void)xdLoopViewdidSelectedAtIndex:(NSInteger)index;

@end

@interface XDLoopCell : UICollectionViewCell
@property (nonatomic, weak) id <XDLoopCellDelegate> delegate;

- (void)configCellWithSource:(NSString *)source atIndex:(NSInteger)idex;
@end
