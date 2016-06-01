//
//  PostVM.swift
//  BeautyPop
//
//  Created by Mac on 17/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class PostVM: PostVMLite {
    
    var ownerNumProducts: Int = 0
    var ownerNumFollowers: Int = 0
    var body: String = ""
    var categoryId: Int = 0
    var categoryName: String = ""
    var categoryIcon: String = ""
    var categoryType: String = ""
    var latestComments: [CommentVM] = []
    var isOwner: Bool = false
    var isFollowingOwner: Bool = false
    var deviceType: String = ""
    var ownerLastLogin: Double = 0
    
    var subCategoryId: Int = 0
    var subCategoryName: String = ""
    var subCategoryIcon: String = ""
    var subCategoryType: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        ownerNumProducts<-map["ownerNumProducts"]
        ownerNumFollowers<-map["ownerNumFollowers"]
        body<-map["body"]
        categoryId<-map["categoryId"]
        categoryName<-map["categoryName"]
        categoryIcon<-map["categoryIcon"]
        categoryType<-map["categoryType"]
        latestComments<-map["latestComments"]
        isOwner<-map["isOwner"]
        isFollowingOwner<-map["isFollowingOwner"]
        deviceType<-map["deviceType"]
        ownerLastLogin<-map["ownerLastLogin"]
        subCategoryId<-map["subCategoryId"]
        subCategoryName<-map["subCategoryName"]
        subCategoryIcon<-map["subCategoryIcon"]
        subCategoryType<-map["subCategoryType"]
    }
}