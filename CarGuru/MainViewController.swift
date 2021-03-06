//
//  MainViewController.swift
//  CarGuru
//
//  Created by Truong Vo on 11/1/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import Alamofire
import PagedArray
import AERecord

let WA_KEY = "coding-puzzle-client-449cc9d"
let PAGE_SIZE = 15
let PRELOAD_MARGIN = 10

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var loading: UIActivityIndicatorView!
    
    var manufacturersPagedArray: PagedArray<Manufacturer>!
    var firstLoad = true
    var shouldPreload = true
    var dataLoadingOperations = [Int: Request]()
    var selectedManufacturer: Manufacturer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Manufacturers"
        
        // Loading indicator
        self.loading = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.loading.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.loading)
        
        // Start loading data
        self.loadDataIfNeededForRow(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showCarsList" {
            let carsViewController = segue.destination as! CarsViewController
            carsViewController.selectedManufacturer = self.selectedManufacturer!
        }
    }
    
    // MARK: - Data & Networking
    
    func loadDataIfNeededForRow(_ row: Int) {
        // TODO: check cached data from Core Data first
        
        if self.firstLoad {
            self.loadDataForPage(0)
            return
        }
        
        let currentPage = self.manufacturersPagedArray.page(for: row)
        if self.needsLoadDataForPage(currentPage) {
            self.loadDataForPage(currentPage)
        }
        
        let preloadIndex = row + PRELOAD_MARGIN
        if preloadIndex < self.manufacturersPagedArray.endIndex && shouldPreload {
            let preloadPage = self.manufacturersPagedArray.page(for: preloadIndex)
            if preloadPage > currentPage && self.needsLoadDataForPage(preloadPage) {
                self.loadDataForPage(preloadPage)
            }
        }
    }
    
    func needsLoadDataForPage(_ page: Int) -> Bool {
        return self.manufacturersPagedArray.elements[page] == nil && self.dataLoadingOperations[page] == nil
    }
    
    func loadDataForPage(_ page: Int) {
        let urlString = "http://api.wkda-test.com/v1/car-types/manufacturer?page=\(page)&pageSize=\(PAGE_SIZE)&wa_key=\(WA_KEY)"
        self.loading.startAnimating()
        let request = Alamofire.request(urlString).responseJSON { response in
            self.loading.stopAnimating()
            
            if let JSON: NSDictionary = response.result.value as? NSDictionary {
                print("JSON: \(JSON)")
                
                if self.firstLoad {
                    // Init manufacturersPagedArray
                    let totalPageCount = JSON.object(forKey: "totalPageCount") as! Int
                    let pSize = JSON.object(forKey: "pageSize") as! Int
                    self.manufacturersPagedArray = PagedArray<Manufacturer>(count: totalPageCount * pSize, pageSize: pSize)
                    self.manufacturersPagedArray.updatesCountWhenSettingPages = true
                }
                
                let previousTotalPageCount = self.manufacturersPagedArray.count // to detect the change of total elements count
                print("PREVIOUS count = \(previousTotalPageCount)")
                
                let jsonData: NSDictionary? = JSON.object(forKey: "wkda") as? NSDictionary
                if jsonData != nil {
                    var pageData: [Manufacturer] = []
                    for (key, value) in jsonData! {
                        let manufacturer = Manufacturer.firstOrCreate(with: ["id": key, "name" : value])
                        AERecord.saveAndWait()
                        pageData.insert(manufacturer, at: 0)
                    }
                    
                    // Alphabetical sorting & set page elements
                    pageData.sort(by: { (this: Manufacturer, that: Manufacturer) -> Bool in
                        this.id! < that.id!
                    })
                    self.manufacturersPagedArray.set(pageData, forPage: page)
                    
                    let currentTotalPageCount = self.manufacturersPagedArray.count
                    print("CURRENT count = \(currentTotalPageCount)")
                    
                    // Reload cells
                    if self.firstLoad || previousTotalPageCount != currentTotalPageCount {
                        self.firstLoad = false
                        self.tableView.reloadData()
                    } else {
                        let indexes = self.manufacturersPagedArray.indexes(for: page)
                        if let indexPathsToReload = self.visibleIndexPathsForIndexes(indexes) {
                            self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                        }
                    }
                    
                    // Cleanup
                    self.dataLoadingOperations[page] = nil
                }
            }
        }
        
        self.dataLoadingOperations[page] = request
    }
    
    private func visibleIndexPathsForIndexes(_ indexes: CountableRange<Int>) -> [IndexPath]? {
        return tableView.indexPathsForVisibleRows?.filter { indexes.contains(($0 as NSIndexPath).row) }
    }

}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firstLoad ? 0 : self.manufacturersPagedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.loadDataIfNeededForRow((indexPath as NSIndexPath).row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManufacturerCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let manufacturer = self.manufacturersPagedArray[indexPath.row]
        cell.textLabel?.text = manufacturer == nil ? "Loading..." : manufacturer!.name
        cell.tintColor = UIColor.white
        
        // Set background colors
        if indexPath.row % 2 == 0 {
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor(red:0.455, green:0.710, blue:0.898, alpha:1.00)
            cell.backgroundColor = bgColorView.backgroundColor
            cell.backgroundView = bgColorView
            cell.textLabel?.textColor = UIColor.white
        } else {
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.white
            cell.backgroundColor = bgColorView.backgroundColor
            cell.backgroundView = bgColorView
            cell.textLabel?.textColor = UIColor.black
        }
    }
    
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedManufacturer = self.manufacturersPagedArray[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        // See segue for pushViewController action
    }
    
}

