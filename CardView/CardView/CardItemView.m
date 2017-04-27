//
//  CardItemView.m
//  CardListView
//
//  Created by Johnny on 2017/4/26.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import "CardItemView.h"

@interface CardItemView ()

@property (assign, nonatomic) CGPoint originalCenter;
@property (assign, nonatomic) CGFloat currentAngle;
@property (assign, nonatomic) BOOL isLeft;

@end

@implementation CardItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        [self initView];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    [self addPanGest];
    [self configLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.originalCenter = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0);
}

- (void)addPanGest {
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestHandle:)];
    [self.contentView addGestureRecognizer:pan];
}

- (void)configLayer {
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.shouldRasterize = YES;
}

- (void)panGestHandle:(UIPanGestureRecognizer *)panGest {
    if (panGest.state == UIGestureRecognizerStateChanged) {
        
        CGPoint movePoint = [panGest translationInView:self.contentView];
        _isLeft = (movePoint.x < 0);
        
        self.contentView.center = CGPointMake(self.contentView.center.x + movePoint.x, self.contentView.center.y + movePoint.y);
        
        CGFloat angle = (self.contentView.center.x - self.frame.size.width / 2.0) / self.frame.size.width / 4.0;
        _currentAngle = angle;

//        self.contentView.transform = CGAffineTransformMakeRotation(angle);
        
        [panGest setTranslation:CGPointZero inView:self.contentView];
        
        if ([self.delegate respondsToSelector:@selector(cardItemViewDidMoveRate:anmate:)]) {
            CGFloat rate = fabs(angle)/0.15>1 ? 1 : fabs(angle)/0.15;
            [self.delegate cardItemViewDidMoveRate:rate anmate:NO];
        }
        
    } else if (panGest.state == UIGestureRecognizerStateEnded) {
        
        CGPoint vel = [panGest velocityInView:self.contentView];
        if (vel.x > 800 || vel.x < - 800) {
            [self remove];
            return ;
        }
        if (self.frame.origin.x + self.frame.size.width > 150 && self.frame.origin.x < self.frame.size.width - 150) {
            [UIView animateWithDuration:0.5 animations:^{
                self.contentView.center = _originalCenter;
                self.contentView.transform = CGAffineTransformMakeRotation(0);
                if ([self.delegate respondsToSelector:@selector(cardItemViewDidMoveRate:anmate:)]) {
                    [self.delegate cardItemViewDidMoveRate:0 anmate:YES];
                }
            }];
        } else {
            [self remove];
        }
    }
}

- (void)remove {
    [self removeWithLeft:_isLeft];
}

- (void)removeWithLeft:(BOOL)left {
    if ([self.delegate respondsToSelector:@selector(cardItemViewDidMoveRate:anmate:)]) {
        [self.delegate cardItemViewDidMoveRate:1 anmate:YES];
    }
    [UIView animateWithDuration:0.2 animations:^{
        if (!left) {
            self.contentView.center = CGPointMake(self.frame.size.width + 1000, self.center.y + _currentAngle * self.frame.size.height + (_currentAngle == 0 ? 100 : 0));
        } else {
            self.contentView.center = CGPointMake(- 1000, self.center.y - _currentAngle * self.frame.size.height + (_currentAngle == 0 ? 100 : 0));
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(cardItemViewDidRemoveFromSuperView:)]) {
                [self.delegate cardItemViewDidRemoveFromSuperView:self];
            }
        }
    }];
}

@end
