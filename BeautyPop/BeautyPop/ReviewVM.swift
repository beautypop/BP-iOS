//
//  ReviewVM.swift
//  BeautyPop
//
//  Created by admin on 26/05/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import ObjectMapper

class ReviewVM: BaseArgVM {
    var id: Int = 0
    var userId: Int = 0
    var userName: String = ""
    var postId: Int = 0
    var postImageId: Int = 0
    var review:String = ""
    var score: Double = 0.0
    var reviewDate: Double = 0.0
    
    override func mapping(map: ObjectMapper.Map) {
        id<-map["id"]
        userId<-map["userId"]
        userName<-map["userName"]
        postId<-map["postId"]
        postImageId<-map["postImageId"]
        review<-map["review"]
        score<-map["score"]
        reviewDate<-map["reviewDate"]
    }
}
