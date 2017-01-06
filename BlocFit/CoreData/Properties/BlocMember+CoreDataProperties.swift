//
//  BlocMember+CoreDataProperties.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/13/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData

extension BlocMember {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlocMember> {
        return NSFetchRequest<BlocMember>(entityName: "BlocMember")
    }

    @NSManaged public var totalScore: Int32
    @NSManaged public var trusted: Bool
    @NSManaged public var username: String?
    @NSManaged public var firstname: String?
    @NSManaged public var owner: Owner?
    @NSManaged public var runs: NSSet?

}

// MARK: Generated accessors for runs
extension BlocMember {

    @objc(addRunsObject:)
    @NSManaged public func addToRuns(_ value: Run)

    @objc(removeRunsObject:)
    @NSManaged public func removeFromRuns(_ value: Run)

    @objc(addRuns:)
    @NSManaged public func addToRuns(_ values: NSSet)

    @objc(removeRuns:)
    @NSManaged public func removeFromRuns(_ values: NSSet)

}
