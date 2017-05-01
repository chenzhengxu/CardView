//
//  CustomItemView.m
//  CardView
//
//  Created by Johnny on 2017/5/1.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import "CustomItemView.h"

@implementation CustomItemView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [[[NSBundle mainBundle] loadNibNamed:@"CustomItemView" owner:nil options:nil] firstObject];
    [self setValue:reuseIdentifier forKey:@"reuseIdentifier"];
    [self initView];
    [self.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://imgsrc.baidu.com/forum/pic/item/b74543a98226cffc748a1d47b9014a90f703eaa7.jpg"]]]];
    return self;
}

@end
