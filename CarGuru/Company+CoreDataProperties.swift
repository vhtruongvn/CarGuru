//
//  Company+CoreDataProperties.swift
//  CarGuru
//
//  Created by Truong Vo on 11/1/17.
//  Copyright © 2017 Truong Vo. All rights reserved.
//

import Foundation
import CoreData


extension Company {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Company> {
        return NSFetchRequest<Company>(entityName: "Company");
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var hasMany: NSSet?

}

// MARK: Generated accessors for hasMany
extension Company {

    @objc(addHasManyObject:)
    @NSManaged public func addToHasMany(_ value: Car)

    @objc(removeHasManyObject:)
    @NSManaged public func removeFromHasMany(_ value: Car)

    @objc(addHasMany:)
    @NSManaged public func addToHasMany(_ values: NSSet)

    @objc(removeHasMany:)
    @NSManaged public func removeFromHasMany(_ values: NSSet)

}
