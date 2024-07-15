//
//  ViewController.m
//  ScrollTest
//
//  Created by Harwyn T'an on 2024/4/18.
//

#import "ViewController.h"
#import "CustomFlowLayout.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 160) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    
    // 创建大圆路径
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 200, 200)];

    // 创建圆角矩形路径
    UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(150, 150, 100, 100) cornerRadius:15];

    // 将圆角矩形路径添加到大圆路径上，形成一个组合路径
    [circlePath appendPath:roundedRectPath];

    // 使用evenodd规则来创建最终的遮罩形状
    circlePath.usesEvenOddFillRule = YES;
    
    // 创建一个CAShapeLayer作为遮罩
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = circlePath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;

    // 创建UIImageView并加载UIImage
    UIImageView *imageView = [[UIImageView alloc] init/*WithImage:[UIImage imageNamed:@"yourImageName"]*/];
    imageView.backgroundColor = [UIColor redColor];

    // 将imageView的frame调整为遮罩的大小，确保遮罩能够完全覆盖图像
    imageView.frame = CGRectMake(0, 300, 200, 200);

    // 将CAShapeLayer设置为imageView的遮罩
    imageView.layer.mask = maskLayer;
    imageView.layer.cornerRadius = 100;
    imageView.layer.masksToBounds = YES;
    
    [self.view addSubview:imageView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100; // 假设有10个Cell
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor]; // 根据需要调整
    return cell;
}
@end
