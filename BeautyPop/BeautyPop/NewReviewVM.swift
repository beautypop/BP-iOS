//
//  NewReviewVM.swift
//  BeautyPop
//
//  Created by admin on 01/06/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import ObjectMapper

class NewReviewVM: BaseArgVM {

    var conversationOrderId: Int = 0
    var score: Double = 0.0
    var review: String = ""
    
    override func mapping(map: ObjectMapper.Map) {
        conversationOrderId<-map["conversationOrderId"]
        score<-map["score"]
        review<-map["review"]
    }
    
}