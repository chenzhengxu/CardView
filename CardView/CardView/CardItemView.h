//
//  CardItemView.h
//  CardListView
//
//  Created by Johnny on 2017/4/26.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardItemView;

@protocol CardItemViewDelegate <NSObject>
/**  itemView从父视图移除*/
- (void)cardItemViewDidRemoveFromSuperView:(CardItemView *)CardItemView;
/**  item移动了多少角度，是否有动画*/
- (void)cardItemViewDidMoveRate:(CGFloat)rate anmate:(BOOL)anmate;

@end

@interface CardItemView : UIView

/**  代理*/
@property (weak, nonatomic) id<CardItemViewDelegate> delegate;
/**  标识符*/
@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

/**  初始化视图*/
- (void)initView;
/**  初始化视图，绑定标识符*/
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
/**  从父视图移除，是否从左侧*/
- (void)removeWithLeft:(BOOL)left;

@end
