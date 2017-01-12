//
//  Car+CoreDataProperties.swift
//  CarGuru
//
//  Created by Truong Vo on 11/1/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var manufacturer: Manufacturer?

}
