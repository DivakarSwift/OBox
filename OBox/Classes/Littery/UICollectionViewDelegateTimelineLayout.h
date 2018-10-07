//
//  UICollectionViewDelegateTimelineLayout.h
//  AudioBox
//
//  Created by kegebai on 2018/8/20.
//  Copyright © 2018年 kegebai. All rights reserved.
//

@protocol UICollectionViewDelegateTimelineLayout <UICollectionViewDelegate>

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 */
- (void)collectionView:(UICollectionView *)collectionView willDeleteItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param fromIndexPath <#fromIndexPath description#>
 @param toIndexPath <#toIndexPath description#>
 */
- (void)collectionView:(UICollectionView *)collectionView didMoveMediaItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param width <#width description#>
 @param indexPath <#indexPath description#>
 */
- (void)collectionView:(UICollectionView *)collectionView didAdjustToWidth:(CGFloat)width forItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param point <#point description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (BOOL)collectionView:(UICollectionView *)collectionView canAdjustToPosition:(CGPoint)point forItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param point <#point description#>
 @param indexPath <#indexPath description#>
 */
- (void)collectionView:(UICollectionView *)collectionView didAdjustToPosition:(CGPoint)point forItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView widthForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 <#Description#>
 
 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (CGPoint)collectionView:(UICollectionView *)collectionView positionForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
