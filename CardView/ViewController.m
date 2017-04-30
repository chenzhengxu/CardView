//
//  ViewController.m
//  CardListView
//
//  Created by Johnny on 2017/4/26.
//  Copyright © 2017年 Johnny. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"

@interface ViewController () <CardViewDelegate, CardViewDataSource>

@property (weak, nonatomic) IBOutlet CardView *cardView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    self.array = [NSMutableArray new];
    for (int i=0; i<10; i++) {
        [self.array addObject:@(i)];
    }
    
    [self.dataArray addObjectsFromArray:self.array];
    
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
    [self.cardView reloadData];
}

- (void)cardViewNeedMoreData:(CardView *)cardView {
    [self performSelector:@selector(moreData) withObject:nil afterDelay:5];
}

- (void)moreData {
    [self.dataArray addObjectsFromArray:self.array];
    [self.cardView reloadData];
}

- (CardItemView *)cardView:(CardView *)cardView itemViewAtIndex:(NSInteger)index {
    static NSString *reuseIdentitfier = @"card";
    CardItemView *itemView = [cardView dequeueReusableCellWithIdentifier:reuseIdentitfier];
    if (itemView == nil) {
        itemView = [[CardItemView alloc] initWithReuseIdentifier:reuseIdentitfier];
    }
    itemView.contentView.backgroundColor = [UIColor colorWithRed:120/255.0 green:194/255.0 blue:234/255.0 alpha:1];
    if (index%2 == 0) {
        itemView.contentView.backgroundColor = [UIColor colorWithRed:175/255.0 green:222/255.0 blue:228/255.0 alpha:1];
    }
    return itemView;
}

- (NSInteger)numberOfItemViewsInCardView:(CardView *)cardView {
    return self.dataArray.count;
}

@end
