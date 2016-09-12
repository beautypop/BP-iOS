//
//  NewViewController.swift
//  BeautyPop
//
//  Created by admin on 08/09/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit

class NewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    var uiCollectionView: UICollectionView!
    var imageArray = ["ic_image_load_1","ic_image_load_2","ic_image_load_3","ic_image_load_4","ic_image_load_5","ic_image_load_6","ic_image_load_7","ic_image_load_8","ic_image_load_9","ic_image_load_10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! TrendsViewCell
       /* self.uiCollectionView = cell.viewWithTag(0) as! UICollectionView
        self.uiCollectionView.dataSource = self
        self.uiCollectionView.delegate = self*/
        
        return cell
    }
    
    
    
    //Collection View  Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! ThemeCollectionViewCell
        return cell
        
    }
       
    
    
}