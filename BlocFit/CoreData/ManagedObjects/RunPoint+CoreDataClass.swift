//
//  RunPoint+CoreDataClass.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import CoreLocation
import CoreData

public class RunPoint: NSManagedObject {
    
    static let entityName = "RunPoint"
    
    /*
     longitude: Double
     latitude: Double
     timestamp: NSDate?
     metersFromLastPoint: Double
     run: Run?
    */
    class func create(
        latitude: Double,
        longitude: Double,
        run: Run,
        lastRunPoint: RunPoint?, // must pass in nil if first run point
        context: NSManagedObjectContext)
        throws -> RunPoint? {
            
        var runPoint: RunPoint?
            
        context.performAndWait {
            runPoint = NSEntityDescription.insertNewObject(
                forEntityName: RunPoint.entityName,
                into: context) as? RunPoint
            
            runPoint?.run = run
            runPoint?.timestamp = NSDate()
            runPoint?.latitude = latitude
            runPoint?.longitude = longitude
            
            if let lastLatitude = lastRunPoint?.latitude,
                let lastLongitude = lastRunPoint?.longitude {
                
                let current2DCoordinates = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude)
                let last2DCoordinates = CLLocationCoordinate2D(
                    latitude: lastLatitude,
                    longitude: lastLongitude)
                
                let currentLocation = CLLocation(
                    latitude: current2DCoordinates.latitude,
                    longitude: current2DCoordinates.longitude)
                let lastLocation = CLLocation(
                    latitude: last2DCoordinates.latitude,
                    longitude: last2DCoordinates.longitude)
                
                let distance = currentLocation.distance(from: lastLocation)
                runPoint?.metersFromLastPoint = distance
                
            } else {
                runPoint?.metersFromLastPoint = 0
            }
        }
            
        try context.save()
            
        return runPoint
    }
    
    func delete() throws {
        self.managedObjectContext?.delete(self)
        try self.managedObjectContext?.save()
    }
}
