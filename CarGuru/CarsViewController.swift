//
//  CarsViewController.swift
//  CarGuru
//
//  Created by Truong Vo on 12/1/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import UIKit
import Alamofire
import PagedArray
import AERecord

class CarsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var loading: UIActivityIndicatorView!
    
    var selectedManufacturer: Manufacturer!
    var carsPagedArray: PagedArray<Car>!
    var firstLoad = true
    var shouldPreload = true
    var dataLoadingOperations = [Int: Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.selectedManufacturer.name!
        
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
    }
    
    // MARK: - Data & Networking
    
    func loadDataIfNeededForRow(_ row: Int) {
        // TODO: check cached data from Core Data first
        
        if self.firstLoad {
            self.loadDataForPage(0)
            return
        }
        
        let currentPage = self.carsPagedArray.page(for: row)
        if self.needsLoadDataForPage(currentPage) {
            self.loadDataForPage(currentPage)
        }
        
        let preloadIndex = row + PRELOAD_MARGIN
        if preloadIndex < self.carsPagedArray.endIndex && shouldPreload {
            let preloadPage = self.carsPagedArray.page(for: preloadIndex)
            if preloadPage > currentPage && self.needsLoadDataForPage(preloadPage) {
                self.loadDataForPage(preloadPage)
            }
        }
    }
    
    func needsLoadDataForPage(_ page: Int) -> Bool {
        return self.carsPagedArray.elements[page] == nil && self.dataLoadingOperations[page] == nil
    }
    
    func loadDataForPage(_ page: Int) {
        let urlString = "http://api.wkda-test.com/v1/car-types/main-types?manufacturer=\(selectedManufacturer.id!)&page=\(page)&pageSize=\(PAGE_SIZE)&wa_key=\(WA_KEY)"
        self.loading.startAnimating()
        let request = Alamofire.request(urlString).responseJSON { response in
            self.loading.stopAnimating()
            
            if let JSON: NSDictionary = response.result.value as? NSDictionary {
                print("JSON: \(JSON)")
                
                if self.firstLoad {
                    // Init carsPagedArray
                    let totalPageCount = JSON.object(forKey: "totalPageCount") as! Int
                    let pSize = JSON.object(forKey: "pageSize") as! Int
                    self.carsPagedArray = PagedArray<Car>(count: totalPageCount * pSize, pageSize: pSize)
                    self.carsPagedArray.updatesCountWhenSettingPages = true
                }
                
                let previousTotalPageCount = self.carsPagedArray.count // to detect the change of total elements count
                print("PREVIOUS count = \(previousTotalPageCount)")
                
                let jsonData: NSDictionary? = JSON.object(forKey: "wkda") as? NSDictionary
                if jsonData != nil {
                    var pageData: [Car] = []
                    for (key, value) in jsonData! {
                        let car = Car.firstOrCreate(with: ["id": key, "name" : value])
                        car.manufacturer = self.selectedManufacturer
                        AERecord.saveAndWait()
                        pageData.insert(car, at: 0)
                    }
                    
                    // Alphabetical sorting & set page elements
                    pageData.sort(by: { (this: Car, that: Car) -> Bool in
                        this.id! < that.id!
                    })
                    self.carsPagedArray.set(pageData, forPage: page)
                    
                    let currentTotalPageCount = self.carsPagedArray.count
                    print("CURRENT count = \(currentTotalPageCount)")
                    
                    // Reload cells
                    if self.firstLoad || previousTotalPageCount != currentTotalPageCount {
                        self.firstLoad = false
                        self.tableView.reloadData()
                    } else {
                        let indexes = self.carsPagedArray.indexes(for: page)
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

extension CarsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firstLoad ? 0 : self.carsPagedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.loadDataIfNeededForRow((indexPath as NSIndexPath).row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let car = self.carsPagedArray[indexPath.row]
        cell.textLabel?.text = car == nil ? "Loading..." : car!.name
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

extension CarsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedcar = self.carsPagedArray[indexPath.row]
        if selectedcar != nil {
            let alertController = UIAlertController(title: "You have selected", message: "Manufacturer: \(self.selectedManufacturer.name!)\nModel: \(selectedcar!.name!)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
