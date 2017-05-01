//
//  CardView.m
//  CardView
//
//  Created by Johnny on 2017/4/26.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import "CardView.h"
#import "CardItemView.h"

static const NSInteger ITEM_VIEW_COUNT = 4;     //显示的item个数 必须大于2
static const NSInteger AHEAD_ITEM_COUNT = 5;    //提前几张view开始提醒刷新

@interface CardView () <CardItemViewDelegate>

@property (assign, nonatomic) NSInteger itemCount;      //总共的item数量
@property (assign, nonatomic) NSInteger removedCount;   //已经被移除的view个数
@property (assign, nonatomic) BOOL isWorking;           //是否正在移除动画中，不去调用itemview的移除方法
@property (assign, nonatomic) BOOL isAskingMoreData;    //是否已向代理请求数据 数据回来的时候进行状态重置
@property (copy, nonatomic) NSMutableDictionary *reuseDict;     //缓存池字典

@end

@implementation CardView

- (CardItemView *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSMutableArray *mutableArray = self.reuseDict[identifier];
    if (mutableArray) {
        if (mutableArray.count>0) {
            CardItemView *itemView = [mutableArray lastObject];
            [mutableArray removeLastObject];
            return itemView;
        }
    }
    return nil;
}

- (void)deleteTheTopItemViewWithLeft:(BOOL)left {
    if (self.isWorking) {
        return;
    }
    CardItemView *itemView = (CardItemView *)self.subviews.lastObject;
    if (itemView) {
        self.isWorking = YES;
        [itemView removeWithLeft:left];
    }
}

- (void)reloadData {
    if (_dataSource == nil) {
        return ;
    }
    self.isAskingMoreData = NO;
    self.itemCount = [self numberOfItemViews];
    
    if (self.subviews.count < ITEM_VIEW_COUNT) {
        for (NSInteger i = self.subviews.count; i < ITEM_VIEW_COUNT; i ++) {
            [self insertCard:self.removedCount+i isReload:YES];
        }
        [self sortCardsWithRate:0 animate:YES];
    }
}

#pragma mark - Sort

- (void)sortCardsWithRate:(CGFloat)rate animate:(BOOL)isAnmate {
    for (int i=1; i<self.subviews.count; i++) {
        NSInteger index = self.subviews.count-i-1;
        CardItemView *card = self.subviews[index];
        card.userInteractionEnabled = NO;
        NSInteger y = i>ITEM_VIEW_COUNT-2 ? ITEM_VIEW_COUNT-2 : i;
        CGFloat realRate = y-rate>0 ? y-rate : 0;
        if (i == (ITEM_VIEW_COUNT-1)) {
            realRate = y;
        }
        CGFloat animationTime = isAnmate ? 0.2 : 0;
        [UIView animateKeyframesWithDuration:animationTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [self transformCard:card withRate:realRate];
        } completion:nil];
    }
}

- (void)transformCard:(CardItemView *)card withRate:(CGFloat)rate {
    CGAffineTransform scaleTransfrom = CGAffineTransformMakeScale(1 - 0.02 * rate, 1 - 0.02 * rate);
    card.transform = CGAffineTransformTranslate(scaleTransfrom, 0, 10*rate);
}

#pragma mark - Insert

- (void)insertCard:(NSInteger)index isReload:(BOOL)isReload {
    if (index >= self.itemCount) {
        return;
    }
    CardItemView *itemView = [self itemViewAtIndex:index];
    if (itemView.delegate == nil) { //初始化的itemView 不是缓存池的
        itemView.delegate = self;
        [itemView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestHandle:)]];
    } else {
        itemView.transform = CGAffineTransformMakeRotation(0);
    }
    CGSize size = [self itemViewSizeAtIndex:index];
    [self insertSubview:itemView atIndex:0];
    itemView.tag = index+1;
    itemView.frame = CGRectMake(self.frame.size.width / 2.0 - size.width / 2.0, self.frame.size.height / 2.0 - size.height / 2.0, size.width, size.height);
    itemView.userInteractionEnabled = YES;
    if (!isReload) {
        if ((index-self.removedCount) == (ITEM_VIEW_COUNT-1)) {
            NSInteger rate = ITEM_VIEW_COUNT-2;
            [self transformCard:itemView withRate:rate];
        }
    }
}

#pragma mark - CardViewDataSource

- (CGSize)itemViewSizeAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(cardView:sizeForItemViewAtIndex:)] && index < [self numberOfItemViews]) {
        CGSize size = [self.dataSource cardView:self sizeForItemViewAtIndex:index];
        if (size.width > self.frame.size.width || size.width == 0) {
            size.width = self.frame.size.width;
        } else if (size.height > self.frame.size.height || size.height == 0) {
            size.height = self.frame.size.height;
        }
        return size;
    }
    return self.frame.size;
}

- (CardItemView *)itemViewAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(cardView:itemViewAtIndex:)]) {
        CardItemView *itemView = [self.dataSource cardView:self itemViewAtIndex:index];
        if (itemView == nil) {
            return [[CardItemView alloc] init];
        } else {
            return itemView;
        }
    }
    return [[CardItemView alloc] init];
}

- (NSInteger)numberOfItemViews {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemViewsInCardView:)]) {
        return [self.dataSource numberOfItemViewsInCardView:self];
    }
    return 0;
}

#pragma mark - CardViewDelegate

- (void)tapGestHandle:(UITapGestureRecognizer *)tapGest {
    if ([self.delegate respondsToSelector:@selector(cardView:didClickItemAtIndex:)]) {
        [self.delegate cardView:self didClickItemAtIndex:tapGest.view.tag - 1];
    }
}

#pragma mark - CardItemViewDelegate

- (void)cardItemViewDidRemoveFromSuperView:(CardItemView *)cardItemView {
    self.isWorking = NO;
    self.removedCount ++;
    [self insertItemViewToReuseDict:cardItemView];
    [self insertCard:self.removedCount+ITEM_VIEW_COUNT-1 isReload:NO];
    CardItemView *card = [self.subviews lastObject];
    card.userInteractionEnabled = YES;
    if (self.removedCount + ITEM_VIEW_COUNT > self.itemCount - AHEAD_ITEM_COUNT) {
        if (!self.isAskingMoreData) {
            self.isAskingMoreData = YES;
            if ([self.dataSource respondsToSelector:@selector(cardViewNeedMoreData:)]) {
                [self.dataSource cardViewNeedMoreData:self];
            }
        }
    } else {
        self.isAskingMoreData = NO;
    }
}

- (void)cardItemViewDidMoveRate:(CGFloat)rate anmate:(BOOL)anmate {
    [self sortCardsWithRate:rate animate:anmate];
}

- (void)insertItemViewToReuseDict:(CardItemView *)cardItemView {
    if (cardItemView.reuseIdentifier) {
        NSMutableArray *mutableArray = self.reuseDict[cardItemView.reuseIdentifier];
        if (mutableArray == nil) {
            mutableArray = [[NSMutableArray alloc] init];
        }
        [mutableArray addObject:cardItemView];
        [self.reuseDict setValue:mutableArray forKey:cardItemView.reuseIdentifier];
    }
    [cardItemView removeFromSuperview];
}

#pragma mark Getter

- (NSMutableDictionary *)reuseDict {
    if (_reuseDict == nil) {
        _reuseDict = [[NSMutableDictionary alloc] init];
    }
    return _reuseDict;
}

@end
