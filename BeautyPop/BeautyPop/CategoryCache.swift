//
//  CategoryCache.swift
//  BeautyPop
//
//  Created by Mac on 04/01/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import SwiftEventBus

class CategoryCache {
    
    static var categories: [CategoryVM] = []
    static var themeCategories: [CategoryVM] = []
    static var trendCategories: [CategoryVM] = []
    static var customCategories: [CategoryVM] = []
    
    init() {
    }

    static func refresh() {
        self.refresh(nil, failureCallback: nil)
    }
    
    static func refresh(successCallback: (([CategoryVM]) -> Void)?, failureCallback: ((String) -> Void)?) {
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedSuccess") { result in
            SwiftEventBus.unregister(self)
            
            if ViewUtil.isEmptyResult(result) {
                failureCallback!("Categories returned is empty")
                return
            }
            self.categories.removeAll()
            self.themeCategories.removeAll()
            self.trendCategories.removeAll()
            self.customCategories.removeAll()
            self.categories = []
            self.themeCategories = []
            self.trendCategories = []
            self.customCategories = []
            
            let allCategories = result.object as! [CategoryVM]
            
            for categoryVM in allCategories {
                if ("PUBLIC" == categoryVM.categoryType) {
                    self.categories.append(categoryVM)
                } else if ("THEME" == categoryVM.categoryType) {
                    self.themeCategories.append(categoryVM)
                } else if ("TREND" == categoryVM.categoryType) {
                    self.trendCategories.append(categoryVM)
                } else if ("CUSTOM" == categoryVM.categoryType) {
                    self.customCategories.append(categoryVM)
                } 
            }
            if successCallback != nil {
                successCallback!(categories)
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "categoriesReceivedFailed") { result in
            SwiftEventBus.unregister(self)
            
            if failureCallback != nil {
                var error = "Failed to get categories..."
                if result.object is NSString {
                    error += "\n"+(result.object as! String)
                }
                failureCallback!(error)
            }
        }
        
        ApiController.instance.getCategories()
    }
    
    static func getCategoryById(catId: Int) -> CategoryVM? {
        for index in 0 ..< CategoryCache.categories.count {
            if Int(CategoryCache.categories[index].id) == catId {
                return CategoryCache.categories[index]
            }
        }
        return nil
    }
    
    static func getTrendById(catId: Int) -> CategoryVM? {
        for index in 0 ..< CategoryCache.trendCategories.count {
            if Int(CategoryCache.trendCategories[index].id) == catId {
                return CategoryCache.trendCategories[index]
            }
        }
        return nil
    }
    
    static func getThemeById(catId: Int) -> CategoryVM? {
        for index in 0 ..< CategoryCache.themeCategories.count {
            if Int(CategoryCache.themeCategories[index].id) == catId {
                return CategoryCache.themeCategories[index]
            }
        }
        return nil
    }
    
    static func getCategoryByName(name: String) -> CategoryVM? {
        for index in 0 ..< CategoryCache.categories.count {
            if CategoryCache.categories[index].name == name {
                return CategoryCache.categories[index]
            }
        }
        return nil
    }
    
    static func getTrendsByName(name: String) -> CategoryVM? {
        for index in 0 ..< CategoryCache.trendCategories.count {
            if CategoryCache.trendCategories[index].name == name {
                return CategoryCache.trendCategories[index]
            }
        }
        return nil
    }
    
    static func getThemesByName(name: String) -> CategoryVM? {
        for index in 0 ..< CategoryCache.themeCategories.count {
            if CategoryCache.themeCategories[index].name == name {
                return CategoryCache.themeCategories[index]
            }
        }
        return nil
    }
    
    static func setCategories(cats: [CategoryVM]) {
        CategoryCache.categories = cats
    }
    
    static func getSubCategoryById(catId: Int, subCategories: [CategoryVM]) -> CategoryVM? {
        for index in 0 ..< subCategories.count {
            if Int(subCategories[index].id) == catId {
                return subCategories[index]
            }
        }
        return nil
    }
    
    static func getSubCategoryByName(name: String, subCategories: [CategoryVM]) -> CategoryVM? {
        for index in 0 ..< subCategories.count {
            if subCategories[index].name == name {
                return subCategories[index]
            }
        }
        return nil
    }

}