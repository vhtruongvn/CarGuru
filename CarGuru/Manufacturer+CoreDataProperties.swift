//
//  Manufacturer+CoreDataProperties.swift
//  CarGuru
//
//  Created by Truong Vo on 11/1/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import CoreData


extension Manufacturer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manufacturer> {
        return NSFetchRequest<Manufacturer>(entityName: "Manufacturer");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var cars: NSSet?

}

// MARK: Generated accessors for cars
extension Manufacturer {

    @objc(addCarsObject:)
    @NSManaged public func addToCars(_ value: Car)

    @objc(removeCarsObject:)
    @NSManaged public func removeFromCars(_ value: Car)

    @objc(addCars:)
    @NSManaged public func addToCars(_ values: NSSet)

    @objc(removeCars:)
    @NSManaged public func removeFromCars(_ values: NSSet)

}
