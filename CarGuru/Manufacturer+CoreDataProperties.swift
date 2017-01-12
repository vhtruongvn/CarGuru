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
    @NSManaged public var hasMany: NSSet?

}

// MARK: Generated accessors for hasMany
extension Manufacturer {

    @objc(addHasManyObject:)
    @NSManaged public func addToHasMany(_ value: Car)

    @objc(removeHasManyObject:)
    @NSManaged public func removeFromHasMany(_ value: Car)

    @objc(addHasMany:)
    @NSManaged public func addToHasMany(_ values: NSSet)

    @objc(removeHasMany:)
    @NSManaged public func removeFromHasMany(_ values: NSSet)

}
