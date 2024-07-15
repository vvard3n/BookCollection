//
//  CustomFlowLayout.m
//  ScrollTest
//
//  Created by Harwyn T'an on 2024/4/18.
//

#import "CustomFlowLayout.h"

#define CELL_MARGIN 25.0
#define CELL_WIDTH 60.0
#define CELL_HEIGHT 80.0

@implementation CustomFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    // 设置滚动方向
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 设置cell的大小
    self.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT); // 根据需要调整大小
    // 设置间距
    self.minimumLineSpacing = CELL_MARGIN; // Cell之间的间距，根据需要调整
    self.minimumInteritemSpacing = CELL_MARGIN; // 同一行内Cell之间的间距，根据需要调整
    self.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20); // 边距，根据需要调整
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    // 克隆一份属性数组
    NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [NSMutableArray arrayWithCapacity:originalAttributes.count];
    
    // 屏幕的中心点
    CGFloat centerX = self.collectionView.contentOffset.x + CELL_WIDTH / 2 + 20;
    CGFloat baseCellWidth = self.itemSize.width; // Cell的基础宽度
    CGFloat baseCellHeight = self.itemSize.height; // Cell的基础高度
    CGFloat spacing = self.minimumLineSpacing; // Cell之间的基础间距
    
    // 假设之前不可见的 Cell 宽高间距不变, 那么第一个可见 Cell 的 x 值是不需要重新计算的, 以它作为起点
    CGFloat offsetX = 0;
    for (int i = 0; i < originalAttributes.count; i++) {
        UICollectionViewLayoutAttributes *attributes = originalAttributes[i];
        if (i == 0) {
            offsetX = attributes.frame.origin.x;
        }
        // 克隆属性，避免直接修改原始值
        UICollectionViewLayoutAttributes *attr = [attributes copy];
        
        CGFloat distance = ABS(CGRectGetMidX(attr.frame) - centerX);
        CGFloat normalizedDistance = distance / CELL_WIDTH;
        
        // 根据距离计算缩放比例，距离中心越近，Cell越大
        CGFloat scale = 1 + (1 - normalizedDistance) * 0.5; // 最大放大比例为1.2
        //        scale = MAX(scale, 1);
        
        // 计算新的宽度和高度
        CGFloat newWidth = baseCellWidth * MAX(scale, 1);
        CGFloat newHeight = baseCellHeight * MAX(scale, 1);
        
        // 计算新的x和y值
        CGFloat newX = offsetX;
        CGFloat newY = self.collectionView.bounds.size.height - newHeight;
        
        // 设置新的frame
        attr.frame = CGRectMake(newX, newY, newWidth, newHeight);
        
        // 更新下一个Cell的起始x坐标
        offsetX += newWidth + spacing;
        
        [updatedAttributes addObject:attr];
    }
    
    return updatedAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    // 计算collectionView的可视区域
    CGRect collectionViewBounds = self.collectionView.bounds;
    CGFloat halfWidth = 20 + CELL_WIDTH / 2;//collectionViewBounds.size.width * 0.5;
    CGPoint proposedCenterOffset = CGPointMake(proposedContentOffset.x + halfWidth, proposedContentOffset.y + collectionViewBounds.size.height * 0.5);

    // 获取提议区域中的所有属性
    NSArray *attributes = [self layoutAttributesForElementsInRect:collectionViewBounds];

    // 寻找最接近中心的项
    UICollectionViewLayoutAttributes *candidateAttribute;
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        // 忽略非Cell的属性
        if (attribute.representedElementCategory != UICollectionElementCategoryCell) {
            continue;
        }

        // 当找到第一个属性时，或者当此项更接近中心时，更新候选属性
        if (!candidateAttribute || fabs(attribute.center.x - proposedCenterOffset.x) < fabs(candidateAttribute.center.x - proposedCenterOffset.x)) {
            candidateAttribute = attribute;
        }
    }

    // 基于找到的最接近中心的项，计算新的偏移量
    CGFloat newOffsetX = candidateAttribute.center.x - halfWidth;
    // 确保新的偏移量不会使collectionView滚动到非法区域（超出内容范围）
    CGFloat maxPossibleOffset = self.collectionView.contentSize.width - collectionViewBounds.size.width;
    CGFloat adjustedOffsetX = MAX(MIN(newOffsetX, maxPossibleOffset), 0);

    return CGPointMake(adjustedOffsetX, proposedContentOffset.y);
}

// 当bounds变化时是否应该刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
