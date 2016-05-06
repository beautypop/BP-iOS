//
//  UserVM.swift
//  BeautyPop
//
//  Created by Mac on 12/11/15.
//  Copyright © 2015 MIndNerves. All rights reserved.
//
import ObjectMapper

class UserVM: UserVMLite {
    
    var aboutMe: String = ""
    var location: LocationVM = LocationVM()
    var settings: SettingVM = SettingVM()
    
    override func mapping(map: ObjectMapper.Map) {
        super.mapping(map)
        
        aboutMe<-map["aboutMe"]
        settings<-map["settings"]
        location<-map["location"]
    }
}
