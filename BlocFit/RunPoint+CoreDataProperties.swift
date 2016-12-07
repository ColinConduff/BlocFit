//
//  RunPoint+CoreDataProperties.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/6/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import CoreData

extension RunPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunPoint> {
        return NSFetchRequest<RunPoint>(entityName: "RunPoint")
    }

    @NSManaged public var metersFromLastPoint: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var run: Run?

}
