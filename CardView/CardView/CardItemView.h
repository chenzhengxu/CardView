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

- (void)cardItemViewDidRemoveFromSuperView:(CardItemView *)CardItemView;
- (void)cardItemViewDidMoveRate:(CGFloat)rate anmate:(BOOL)anmate;

@end

@interface CardItemView : UICollectionViewCell

@property (nonatomic, weak) id<CardItemViewDelegate> delegate;

- (void)removeWithLeft:(BOOL)left;

@end
