//
//  Run+CoreDataProperties.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/7/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData

extension Run {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Run> {
        return NSFetchRequest<Run>(entityName: "Run")
    }

    @NSManaged public var endTime: NSDate?
    @NSManaged public var score: Int32
    @NSManaged public var secondsElapsed: Int16
    @NSManaged public var secondsPerMeter: Double
    @NSManaged public var startTime: NSDate?
    @NSManaged public var totalDistanceInMeters: Double
    @NSManaged public var blocMembers: NSSet?
    @NSManaged public var owner: Owner?
    @NSManaged public var runPoints: NSOrderedSet?

}

// MARK: Generated accessors for blocMembers
extension Run {

    @objc(addBlocMembersObject:)
    @NSManaged public func addToBlocMembers(_ value: BlocMember)

    @objc(removeBlocMembersObject:)
    @NSManaged public func removeFromBlocMembers(_ value: BlocMember)

    @objc(addBlocMembers:)
    @NSManaged public func addToBlocMembers(_ values: NSSet)

    @objc(removeBlocMembers:)
    @NSManaged public func removeFromBlocMembers(_ values: NSSet)

}

// MARK: Generated accessors for runPoints
extension Run {

    @objc(insertObject:inRunPointsAtIndex:)
    @NSManaged public func insertIntoRunPoints(_ value: RunPoint, at idx: Int)

    @objc(removeObjectFromRunPointsAtIndex:)
    @NSManaged public func removeFromRunPoints(at idx: Int)

    @objc(insertRunPoints:atIndexes:)
    @NSManaged public func insertIntoRunPoints(_ values: [RunPoint], at indexes: NSIndexSet)

    @objc(removeRunPointsAtIndexes:)
    @NSManaged public func removeFromRunPoints(at indexes: NSIndexSet)

    @objc(replaceObjectInRunPointsAtIndex:withObject:)
    @NSManaged public func replaceRunPoints(at idx: Int, with value: RunPoint)

    @objc(replaceRunPointsAtIndexes:withRunPoints:)
    @NSManaged public func replaceRunPoints(at indexes: NSIndexSet, with values: [RunPoint])

    @objc(addRunPointsObject:)
    @NSManaged public func addToRunPoints(_ value: RunPoint)

    @objc(removeRunPointsObject:)
    @NSManaged public func removeFromRunPoints(_ value: RunPoint)

    @objc(addRunPoints:)
    @NSManaged public func addToRunPoints(_ values: NSOrderedSet)

    @objc(removeRunPoints:)
    @NSManaged public func removeFromRunPoints(_ values: NSOrderedSet)

}
