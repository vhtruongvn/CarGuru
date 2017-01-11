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

class MainViewController: UIViewController {

    var companies: PagedArray<Company>!
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CarGuru"
        
        self.getCarCompanies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Networking
    
    func getCarCompanies() {
        Alamofire.request("http://api.wkda-test.com/v1/car-types/manufacturer?page=\(currentPage)&pageSize=10&wa_key=coding-puzzle-client-449cc9d").responseJSON { response in
            //print(response.request as Any)  // original URL request
            //print(response.response as Any) // HTTP URL response
            //print(response.data as Any)     // server data
            //print(response.result)   // result of response serialization
            
            if let JSON: NSDictionary = response.result.value as? NSDictionary {
                print("JSON: \(JSON)")
                
                let totalPageCount = JSON.object(forKey: "totalPageCount") as! Int
                let pageSize = JSON.object(forKey: "pageSize") as! Int
                if self.companies == nil {
                    self.companies = PagedArray<Company>(count: pageSize, pageSize: totalPageCount)
                }
                
                let jsonData: NSDictionary = JSON.object(forKey: "wkda") as! NSDictionary
                var pageData: [Company] = []
                for (key, value) in jsonData {
                    let company = Company.create(with: ["id": key, "name" : value])
                    AERecord.saveAndWait()
                    pageData.insert(company, at: 0)
                }
                self.companies.set(pageData, forPage: self.currentPage)
                
                print(self.companies)
            }
        }
    }

}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        // set data
        cell.textLabel?.text = "Test"
        
        // set highlight color
        /*let highlightColorView = UIView()
        highlightColorView.backgroundColor = yellow
        cell.selectedBackgroundView = highlightColorView
        cell.textLabel?.highlightedTextColor = UIColor.darkGray*/
    }
    
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

