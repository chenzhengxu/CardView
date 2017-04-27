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
- (void)cardView:(CardView *)cardView didClickItemAtIndex:(NSInteger)index;
@end

@protocol CardViewDataSource <NSObject>
@required
- (NSInteger)numberOfItemViewsInCardView:(CardView *)cardView;
- (CardItemView *)cardView:(CardView *)cardView itemViewAtIndex:(NSInteger)index;
- (void)cardViewNeedMoreData:(CardView *)cardView;
@optional
// default is equal to cardView's bounds
- (CGSize)cardView:(CardView *)cardView sizeForItemViewAtIndex:(NSInteger)index;

@end

@interface CardView : UIView
@property (nonatomic, weak) id <CardViewDataSource> dataSource;
@property (nonatomic, weak) id <CardViewDelegate> delegate;

- (void)deleteTheTopItemViewWithLeft:(BOOL)left;
- (void)reloadData;
@end
