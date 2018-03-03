//
//  CardView.h
//  CardView
//
//  Created by Johnny on 2017/4/26.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardItemView.h"

@class CardView;

@protocol CardViewDelegate <NSObject>

@optional
/**  点击了第几个itemView*/
- (void)cardView:(CardView *)cardView didClickItemAtIndex:(NSInteger)index;

@end

@protocol CardViewDataSource <NSObject>

@required
/**  一共有多少个CardItemView对象*/
- (NSInteger)numberOfItemViewsInCardView:(CardView *)cardView;
/**  返回第几个CardItemView的对象*/
- (CardItemView *)cardView:(CardView *)cardView itemViewAtIndex:(NSInteger)index;
/**  要求请求更多数据*/
- (void)cardViewNeedMoreData:(CardView *)cardView;

@optional
- (CGSize)cardView:(CardView *)cardView sizeForItemViewAtIndex:(NSInteger)index;

@end

@interface CardView : UIView

/**  数据源*/
@property (nonatomic, weak) id <CardViewDataSource> dataSource;
/**  代理*/
@property (nonatomic, weak) id <CardViewDelegate> delegate;

/**  获取标识符的CardItemView对象*/
- (CardItemView *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/**  删除第一个CardItemView对象 是否从左侧*/
- (void)deleteTheTopItemViewWithLeft:(BOOL)left;
/**  重载视图*/
- (void)reloadData;

@end
