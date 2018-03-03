## CardView
模仿探探的卡片流交互控件

![image](https://note.youdao.com/yws/public/resource/7e0d71698fb842913c1df12f88a67bb3/xmlnote/09AA8FE5642B4995A596D21D2F968EE7/1405)

## 如何使用CardView
* 通过CocoaPods安装：```pod 'CardView'```
* 手动导入：
	* 把CardView文件夹内的所有文件拖入工程
	* 导入主要文件：#import "CardView"

```objc
CardView.h                  CardItemView.h            
```

## 控件介绍

**控件模仿了tableview的数据源和代理方法，以及tableviewcell的缓存池逻辑**

```objc
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

```

```objc
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
```

#### 自定义
继承于CardItemView即可进行自定义的卡片流定制

## 缓存池

为了优化内存，建立了缓存池，默认同时显示4个CardItemView对象。

```
@property (copy, nonatomic) NSMutableDictionary *reuseDict;
```

同时最多只有屏幕上可见的CardItemView对象存在内存中，可允许多个不同reuseIdentifier的CardItemView对象进行缓存调用，当第一个CardItemView对象从视图上移除时，依然会保存在缓存池字典中，同时调用

```
- (CardItemView *)cardView:(CardView *)cardView itemViewAtIndex:(NSInteger)index;
```

去获取最后个CardItemView对象，加入在视图显示中。

默认从最后提前5张调用datasource方法，类似于tableview的上拉加载

```
- (void)cardViewNeedMoreData:(CardView *)cardView;
```

## 动画

动画原理，在CardItemView上添加了UIPanGestureRecognizer，根据拖拽手势的action方法```@selector(panGestHandle:)```反馈的拖拽情况，来判断CardItemView对象应该旋转多少角度，是否应该从父视图移除。

```objc
- (void)panGestHandle:(UIPanGestureRecognizer *)panGest {
    if (panGest.state == UIGestureRecognizerStateChanged) {
        CGPoint movePoint = [panGest translationInView:self];
        _isLeft = (movePoint.x < 0);
        self.center = CGPointMake(self.center.x + movePoint.x, self.center.y + movePoint.y);
        
        CGFloat angle = (self.center.x - self.frame.size.width / 2.0) / self.frame.size.width / 4.0;
        _currentAngle = angle;
        self.transform = CGAffineTransformMakeRotation(-angle);
        
        [panGest setTranslation:CGPointZero inView:self];
        if ([self.delegate respondsToSelector:@selector(cardItemViewDidMoveRate:anmate:)]) {
            CGFloat rate = fabs(angle)/0.15>1 ? 1 : fabs(angle)/0.15;
            [self.delegate cardItemViewDidMoveRate:rate anmate:NO];
        }
        
    } else if (panGest.state == UIGestureRecognizerStateEnded) {
        CGPoint vel = [panGest velocityInView:self];
        if (vel.x > 800 || vel.x < - 800) {
            [self remove];
            return ;
        }
        if (self.frame.origin.x + self.frame.size.width > 150 && self.frame.origin.x < self.frame.size.width - 150) {
            [UIView animateWithDuration:0.5 animations:^{
                self.center = _originalCenter;
                self.transform = CGAffineTransformMakeRotation(0);
                if ([self.delegate respondsToSelector:@selector(cardItemViewDidMoveRate:anmate:)]) {
                    [self.delegate cardItemViewDidMoveRate:0 anmate:YES];
                }
            }];
        } else {
            [self remove];
        }
    }
}
```

根据CardItemView对象的下标index来调整每个卡片不同的frame来体现卡片的层叠感。

```objc
CGSize size = [self itemViewSizeAtIndex:index];
[self insertSubview:itemView atIndex:0];
itemView.tag = index+1;
itemView.frame = CGRectMake(self.frame.size.width / 2.0 - size.width / 2.0, self.frame.size.height / 2.0 - size.height / 2.0, size.width, size.height);
```
