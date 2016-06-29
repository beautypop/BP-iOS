//
//  FeedViewAdapter.swift
//  BeautyPop
//
//  Created by Keith Lei on 2/18/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class FeedViewAdapter {

    enum FeedViewItemsLayout {
        case TWO_COLUMNS
        case THREE_COLUMNS
    }
    
    var feedViewItemsLayout = FeedViewItemsLayout.THREE_COLUMNS
    
    var collectionView: UICollectionView
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }

    func bindViewCell(cell: FeedProductCollectionViewCell, feedItem: PostVMLite, index: Int) -> FeedProductCollectionViewCell {
        return bindViewCell(cell, feedItem: feedItem, index: index, showOwner: false)
    }
    
    func bindViewCell(cell: FeedProductCollectionViewCell, feedItem: PostVMLite, index: Int, showOwner: Bool) -> FeedProductCollectionViewCell {
        
        cell.title.font = UIFont.systemFontOfSize(13)
        cell.title.textColor = Color.DARK_GRAY
        cell.title.text = feedItem.title
        
        // load image
        if feedItem.hasImage {
            ImageUtil.displayPostImage(feedItem.images[0], imageView: cell.prodImageView)
        }
        
        // sold tag
        cell.soldImage.hidden = !feedItem.sold
        
        // like count
        cell.likeCount.minimumScaleFactor = 0.01
        cell.likeCount.adjustsFontSizeToFitWidth = true
        cell.likeCount.lineBreakMode = NSLineBreakMode.ByClipping
        //cell.likeCount.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        cell.likeCount.text = String(feedItem.numLikes)
        cell.likeCount.sizeToFit()

        // liked?
        cell.likeImageIns.tag = index
        //cell.likeImageIns.addTarget(self, action: "onLikeBtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if !feedItem.isLiked {
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
        } else {
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
        }

        // price
        //cell.productPrice.font = UIFont.systemFontOfSize(12)
        cell.productPrice.text = ViewUtil.formatPrice(feedItem.price)
        if feedItem.originalPrice != 0 && feedItem.originalPrice != -1 && feedItem.originalPrice != feedItem.price {
            let attrString = NSAttributedString(string: ViewUtil.formatPrice(feedItem.originalPrice), attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
            cell.originalPrice.attributedText = attrString
        } else {
            cell.originalPrice.attributedText = NSAttributedString(string: "")
        }
        
        cell.layer.borderColor = Color.FEED_ITEM_BORDER.CGColor
        cell.layer.borderWidth = 0.5

        // Owner
        if showOwner && cell.userCircleImg != nil {
            cell.userCircleImg.layer.borderColor = Color.WHITE.CGColor
            cell.userCircleImg.layer.borderWidth = CGFloat(2.0)
            cell.userCircleImg.alpha = 0.75
            ImageUtil.displayThumbnailProfileImage(feedItem.ownerId, imageView: cell.userCircleImg)
        }
        
        cell.layer.cornerRadius = getCornerRadius()
        return cell
    }

    func onLikeBtnClick(cell: FeedProductCollectionViewCell, feedItem: PostVMLite) {
        if feedItem.isLiked {
            feedItem.isLiked = false
            feedItem.numLikes -= 1
            cell.likeImageIns.setImage(UIImage(named: "ic_like_tips.png"), forState: UIControlState.Normal)
            cell.likeCount.text = String(feedItem.numLikes)
            ApiController.instance.unlikePost(feedItem.id)
        } else {
            feedItem.isLiked = true
            feedItem.numLikes += 1
            cell.likeImageIns.setImage(UIImage(named: "ic_liked_tips.png"), forState: UIControlState.Normal)
            cell.likeCount.text = String(feedItem.numLikes)
            ApiController.instance.likePost(feedItem.id)
        }
    }
    
    func getFeedItemCellSize(width: CGFloat) -> CGSize {
        var sideSpacing = Constants.FEED_ITEM_3COL_SIDE_SPACING
        var detailsHeight = Constants.FEED_ITEM_3COL_DETAILS_HEIGHT
        if self.feedViewItemsLayout == FeedViewItemsLayout.TWO_COLUMNS {
            sideSpacing = Constants.FEED_ITEM_2COL_SIDE_SPACING
            detailsHeight = Constants.FEED_ITEM_2COL_DETAILS_HEIGHT
        }
        
        let availableWidthForCells: CGFloat = width - (sideSpacing * CGFloat(getFeedColumns() + 1))  // left middle right spacing
        let cellWidth: CGFloat = availableWidthForCells / getFeedColumns()
        let cellHeight = cellWidth + detailsHeight
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    func getFeedViewFlowLayout(viewController: UIViewController) -> UICollectionViewFlowLayout {
        return FeedViewAdapter.getFeedViewFlowLayout(viewController, sideSpacing: getSideSpacing(), lineSpacing: getLineSpacing())
    }
    
    static func getFeedViewFlowLayout(viewController: UIViewController, sideSpacing: CGFloat, lineSpacing: CGFloat) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(viewController.view.bounds.width, viewController.view.bounds.height)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.minimumInteritemSpacing = sideSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = UIEdgeInsetsMake(sideSpacing, sideSpacing, sideSpacing, sideSpacing)
        return flowLayout
    }
    
    static func getNoFeedItemCellSize(width: CGFloat) -> CGSize {
        return CGSizeMake(width, Constants.NO_ITEM_TIP_TEXT_CELL_HEIGHT)
    }
    
    func bindNoItemToolTip(cell: TooltipViewCell, feedType: FeedFilter.FeedType) -> TooltipViewCell {
        
        switch feedType {
        case FeedFilter.FeedType.HOME_EXPLORE:
            cell.toolTipText.text = ""
        case FeedFilter.FeedType.HOME_FOLLOWING:
            cell.toolTipText.text = Constants.NO_FOLLOWING_TEXT
        case FeedFilter.FeedType.CATEGORY_POPULAR:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        case FeedFilter.FeedType.CATEGORY_NEWEST:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        case FeedFilter.FeedType.CATEGORY_PRICE_LOW_HIGH:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        case FeedFilter.FeedType.CATEGORY_PRICE_HIGH_LOW:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        case FeedFilter.FeedType.USER_POSTED:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        case FeedFilter.FeedType.USER_LIKED:
            cell.toolTipText.text = Constants.NO_PRODUCT_TEXT
        default: break
        }
        return cell
    }
    
    func getFeedColumns() -> Int {
        switch self.feedViewItemsLayout {
        case FeedViewItemsLayout.TWO_COLUMNS:
            return 2
        case FeedViewItemsLayout.THREE_COLUMNS: fallthrough
        default:
            return 3
        }
    }
    
    func getCornerRadius() -> CGFloat {
        switch self.feedViewItemsLayout {
        case FeedViewItemsLayout.TWO_COLUMNS:
            return Constants.FEED_ITEM_2COL_CORNER_RADIUS
        case FeedViewItemsLayout.THREE_COLUMNS: fallthrough
        default:
            return Constants.FEED_ITEM_3COL_CORNER_RADIUS
        }
    }
    
    func getSideSpacing() -> CGFloat {
        switch self.feedViewItemsLayout {
        case FeedViewItemsLayout.TWO_COLUMNS:
            return Constants.FEED_ITEM_2COL_SIDE_SPACING
        case FeedViewItemsLayout.THREE_COLUMNS: fallthrough
        default:
            return Constants.FEED_ITEM_3COL_SIDE_SPACING
        }
    }
    
    func getLineSpacing() -> CGFloat {
        switch self.feedViewItemsLayout {
        case FeedViewItemsLayout.TWO_COLUMNS:
            return Constants.FEED_ITEM_2COL_LINE_SPACING
        case FeedViewItemsLayout.THREE_COLUMNS: fallthrough
        default:
            return Constants.FEED_ITEM_3COL_LINE_SPACING
        }
    }
    
    func getDetailsHeight() -> CGFloat {
        switch self.feedViewItemsLayout {
        case FeedViewItemsLayout.TWO_COLUMNS:
            return Constants.FEED_ITEM_2COL_DETAILS_HEIGHT
        case FeedViewItemsLayout.THREE_COLUMNS: fallthrough
        default:
            return Constants.FEED_ITEM_3COL_DETAILS_HEIGHT
        }
    }
}