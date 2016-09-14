//
//  Constants.swift
//  BeautyPop
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let BASE_URL = "http://119.81.228.91"
    static let BASE_IMAGE_URL = "http://119.81.228.91"
    
    static let DEEP_LINK_URL_SCHEME = "beautypop://"
    
    static let DEVICE_TYPE = "IOS";
    static let CURRENCY_SYMBOL = "$"
    
    static let FORGET_PASSWORD_URL: String = Constants.BASE_URL + "/login/password/forgot";
    static let PRIVACY_URL: String = Constants.BASE_URL + "/privacy";
    static let TERMS_URL: String = Constants.BASE_URL + "/terms";
    
    static let HTTP_STATUS_OK = 200;
    static let HTTP_STATUS_BAD_REQUEST = 400;
    
    static let SPLASH_SHOW_DURATION = 0.5
    static let FEED_LOAD_SCROLL_THRESHOLD = CGFloat(500.0)
    static let SHOW_HIDE_BAR_SCROLL_DISTANCE = CGFloat(5.0)
    static let MAIN_BOTTOM_BAR_ALPHA = 0.9
    static let THEME_BOTTOM_BAR_ALPHA = CGFloat(0.6)
    static let THEME_TOP_BAR_ALPHA = CGFloat(0.0)
    
    static let BANNER_REFRESH_TIME_INTERVAL = 4.0
    static let FEED_IDLE_REFRESH_TIME_INTERVAL = 5.0 * 60
    
    // sizes
    static let DEFAULT_BUTTON_CORNER_RADIUS = CGFloat(7)
    static let DEFAULT_CIRCLE_RADIUS = CGFloat(25)
    static let DEFAULT_CORNER_RADIUS = CGFloat(5)
    static let DEFAULT_SPACING = CGFloat(10)
    static let HOME_BANNER_WIDTH_HEIGHT_RATIO = CGFloat(3)
    static let HOME_HEADER_CATEGORY_SELECTOR_COLUMNS = 3
    static let HOME_HEADER_CATEGORY_SELECTOR_EXTRA_HEIGHT = CGFloat(130)
    static let HOME_HEADER_ITEMS_MARGIN_TOTAL = CGFloat(12)         // 3 each x 4
    static let CATEGORY_HEADER_SUBCATEGORY_SELECTOR_COLUMNS = 4
    static let CATEGORY_HEADER_SUBCATEGORY_SELECTOR_EXTRA_HEIGHT = CGFloat(55)
    static let CATEGORY_HEADER_ITEMS_MARGIN_TOTAL = CGFloat(15)     // 3 each x 5
    static let PROFILE_HEADER_HEIGHT = CGFloat(125)
    static let FEED_ITEM_2COL_CORNER_RADIUS = CGFloat(3)
    static let FEED_ITEM_2COL_SIDE_SPACING = CGFloat(7)
    static let FEED_ITEM_2COL_LINE_SPACING = CGFloat(7)
    static let FEED_ITEM_2COL_DETAILS_HEIGHT = CGFloat(50)
    static let FEED_ITEM_3COL_CORNER_RADIUS = CGFloat(0)
    static let FEED_ITEM_3COL_SIDE_SPACING = CGFloat(3)
    static let FEED_ITEM_3COL_LINE_SPACING = CGFloat(7)
    static let FEED_ITEM_3COL_DETAILS_HEIGHT = CGFloat(30)
    static let PRODUCT_INFO_HEIGHT = CGFloat(250)
    static let PRODUCT_SELLER_HEIGHT = CGFloat(75)
    static let PRODUCT_COMMENTS_HEIGHT = CGFloat(50)
    static let PRODUCT_MORE_PRODUCTS_HEIGHT = CGFloat(150)
    static let SELLER_FEED_ITEM_DETAILS_HEIGHT = CGFloat(70)
    static let USER_ACTIVITY_DEFAULT_HEIGHT = CGFloat(70.0)
    static let USER_ACTIVITY_SIDE_MARGIN = CGFloat(100.0)
    static let MESSAGE_BUBBLE_CORNER_RADIUS = CGFloat(5)
    static let MESSAGE_IMAGE_WIDTH = CGFloat(0.65)
    static let MESSAGE_LOAD_MORE_BTN_HEIGHT = CGFloat(0)
    static let IMAGE_RESIZE_DIMENSION = CGFloat(640)
    static let NO_ITEM_TIP_TEXT_CELL_HEIGHT = CGFloat(70)
    static let MORE_PRODUCTS_DIMENSION = CGFloat(100)
    static let MORE_PRODUCTS_EXTRA_HEIGHT = CGFloat(35)
    static let CONVERSATION_ORDER_STATUS_TAG_WIDTH = CGFloat(60)
    static let CONVERSATION_ORDER_STATUS_TAG_MARGIN = CGFloat(15)
    static let THEME_DIMENSION = CGFloat(100)
    static let TREND_PRODUCTS_DIMENSION = CGFloat(100)
    
    static let USER_REVIEW_DEFAULT_HEIGHT = CGFloat(85.0)
    //static let USER_REVIEW_SIDE_MARGIN = CGFloat(30.0)
    
    // strings
    static let ACTIVITY_FIRST_POST = NSLocalizedString("activity_now_seller", comment: "") //"You are now a BeautyPop seller! Your first product has been listed:\n"
    static let ACTIVITY_NEW_POST = NSLocalizedString("activity_new_product", comment: "") // "New product listed:\n"
    static let ACTIVITY_COMMENTED = NSLocalizedString("activity_product_commented", comment: "") // "commented on product:\n"
    static let ACTIVITY_LIKED = NSLocalizedString("activity_product_liked", comment: "") //"liked your product."
    static let ACTIVITY_FOLLOWED = NSLocalizedString("activity_started_following", comment: "") //"started following you."
    static let ACTIVITY_SOLD = NSLocalizedString("activity_sold", comment: "") //"already sold."
    static let ACTIVITY_GAME_BADGE = NSLocalizedString("activity_new_badge_msg", comment: "") // "Congratulations! You got a new badge:\n"
    static let ACTIVITY_TIPS_NEW_USER = NSLocalizedString("activity_tips_new_user", comment: "") // "Congratulations! You got a new badge:\n"
    static let ACTIVITY_SELLER_REVIEW = NSLocalizedString("activity_seller_review", comment: "") // "Congratulations! You got a new badge:\n"
    static let ACTIVITY_BUYER_REVIEW = NSLocalizedString("activity_buyer_review", comment: "") // "Congratulations! You got a new badge:\n"
    
    static let SETTING_EMAIL_NOTIF_NEW_PRODUCT = NSLocalizedString("product_listed", comment: "") //"Product listed"
    static let SETTING_EMAIL_NOTIF_NEW_CHAT = NSLocalizedString("new_chat", comment: "") //"New chat"
    static let SETTING_EMAIL_NOTIF_NEW_COMMENT = NSLocalizedString("new_comment", comment: "") //"New comment on your products"
    static let SETTING_EMAIL_NOTIF_NEW_PROMOTIONS = NSLocalizedString("new_promotions", comment: "") //"New promotions"
    static let SETTING_PUSH_NOTIF_NEW_CHAT = NSLocalizedString("new_chat", comment: "") //"New chat"
    static let SETTING_PUSH_NOTIF_NEW_COMMENT = NSLocalizedString("new_comment", comment: "") //"New comment on your products"
    static let SETTING_PUSH_NOTIF_NEW_FOLLOW = NSLocalizedString("new_follower", comment: "") //"New follower"
    static let SETTING_PUSH_NOTIF_NEW_FEEDBACK = NSLocalizedString("new_review", comment: "") //"New review"
    static let SETTING_PUSH_NOTIF_NEW_PROMOTIONS = NSLocalizedString("new_promotions", comment: "") //"New promotions"
    
    static let NO_FOLLOWINGS = NSLocalizedString("no_followings", comment: "") //"~ No Followings ~"
    static let NO_FOLLOWERS = NSLocalizedString("no_followers", comment: "") //
    
    static let NO_POSTS = NSLocalizedString("no_posts", comment: "") //"~~ No posts ~~"
    static let NO_LIKES = NSLocalizedString("no_likes", comment: "") // "~~ No Likes ~~"
    
    static let CONVERSATION_MESSAGE_COUNT = 20;
    
    static let PRODUCT_SOLD_TEXT = NSLocalizedString("product_sold", comment: "") // "This item has been sold"
    static let PRODUCT_SOLD_CONFIRM_TEXT = NSLocalizedString("confirm_sold", comment: "")
    //"Confirm product has been sold?\nYou will no longer receive chats and orders for this product"
    
    static let DELETE_COMMENT_TEXT = NSLocalizedString("delete_comment", comment: "") //"Delete comment?"
    
    static let PM_ORDER_CANCELLED = NSLocalizedString("pm_order_cancelled", comment: "") //"Order is cancelled"
    static let PM_ORDER_ACCEPTED_FOR_BUYER = NSLocalizedString("pm_order_accepted_for_buyer", comment: "") //"Order is accepted"
    static let PM_ORDER_DECLINED_FOR_BUYER = NSLocalizedString("pm_order_declined_for_buyer", comment: "") //"Order is declined"
    
    static let PM_ORDER_ACCEPTED_FOR_SELLER = NSLocalizedString("pm_order_accepted_for_seller", comment: "") //"Order is accepted"
    static let PM_ORDER_DECLINED_FOR_SELLER = NSLocalizedString("pm_order_declined_for_seller", comment: "") //"Order is declined"
    
    static let NO_PRODUCT_TEXT = NSLocalizedString("no_product_text", comment: "") //"~ No Products ~"
    static let NO_FOLLOWING_TEXT = NSLocalizedString("no_following_text", comment: "") //"~ No Followings ~"
    static let NO_USER_TEXT = NSLocalizedString("no_user_text", comment: "") //"~ No Users ~"
    
    static let SHARING_SELLER_MSG_PREFIX = NSLocalizedString("notif_checkout_msg", comment: "") //"Check out BeautyPop Seller"
}
