//
//  Owner+CoreDataProperties.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/5/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData

extension Owner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owner> {
        return NSFetchRequest<Owner>(entityName: "Owner")
    }

    @NSManaged public var totalScore: Int32
    @NSManaged public var username: String?
    @NSManaged public var blocMembers: NSSet?
    @NSManaged public var runs: NSSet?

}

// MARK: Generated accessors for blocMembers
extension Owner {

    @objc(addBlocMembersObject:)
    @NSManaged public func addToBlocMembers(_ value: BlocMember)

    @objc(removeBlocMembersObject:)
    @NSManaged public func removeFromBlocMembers(_ value: BlocMember)

    @objc(addBlocMembers:)
    @NSManaged public func addToBlocMembers(_ values: NSSet)

    @objc(removeBlocMembers:)
    @NSManaged public func removeFromBlocMembers(_ values: NSSet)

}

// MARK: Generated accessors for runs
extension Owner {

    @objc(addRunsObject:)
    @NSManaged public func addToRuns(_ value: Run)

    @objc(removeRunsObject:)
    @NSManaged public func removeFromRuns(_ value: Run)

    @objc(addRuns:)
    @NSManaged public func addToRuns(_ values: NSSet)

    @objc(removeRuns:)
    @NSManaged public func removeFromRuns(_ values: NSSet)

}
