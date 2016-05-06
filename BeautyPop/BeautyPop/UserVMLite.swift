//
//  User.swift
//  BeautyPop
//
//  Created by Mac on 14/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import ObjectMapper

class UserVMLite: BaseArgVM {

    var id: Int = 0
    var displayName: String = ""
    var name: String = ""
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var numLikes: Int = 0
    var numFollowings: Int = 0
    var numFollowers: Int = 0
    var numProducts: Int = 0
    var numComments: Int = 0
    var numConversationsAsSender: Int = 0
    var numConversationsAsRecipient: Int = 0
    var numCollections: Int = 0
    var numReviews: Int = 0
    var averageReviewScore: Float = 0.0
    var isFollowing: Bool = false
    
    var offset: Double = 0
    
    // admin readonly fields
    var createdDate: Double = 0
    var lastLogin: Double = 0
    var totalLogin: Double = 0
    var isLoggedIn: Bool = false
    var isFBLogin: Bool = false
    var emailValidated: Bool = false
    var newUser: Bool = false
    var isAdmin: Bool = false
    var isPromotedSeller: Bool = false
    var isVerifiedSeller: Bool = false
    var isRecommendedSeller: Bool = false

    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        id<-map["id"]
        displayName<-map["displayName"]
        name<-map["name"]
        email<-map["email"]
        firstName<-map["firstName"]
        lastName<-map["lastName"]
        numLikes<-map["numLikes"]
        numFollowings<-map["numFollowings"]
        numFollowers<-map["numFollowers"]
        numProducts<-map["numProducts"]
        numComments<-map["numComments"]
        numConversationsAsSender<-map["numConversationsAsSender"]
        numConversationsAsRecipient<-map["numConversationsAsRecipient"]
        numCollections<-map["numCollections"]
        numReviews<-map["numReviews"]
        averageReviewScore<-map["averageReviewScore"]
        isFollowing<-map["isFollowing"]
        offset<-map["offset"]
        
        createdDate<-map["createdDate"]
        lastLogin<-map["lastLogin"]
        totalLogin<-map["totalLogin"]
        isLoggedIn<-map["isLoggedIn"]
        isFBLogin<-map["fbLogin"]
        emailValidated<-map["emailValidated"]
        newUser<-map["newUser"]
        isAdmin<-map["isAdmin"]
        isPromotedSeller<-map["isPromotedSeller"]
        isVerifiedSeller<-map["isVerifiedSeller"]
        isRecommendedSeller<-map["isRecommendedSeller"]
    }
}







