//
//  Run+CoreDataClass.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import CoreLocation
import Foundation
import CoreData

public class Run: NSManagedObject {
    
    static let entityName = "Run"
    static let blocMembers = "blocMembers"
    static let runPoints = "runPoints"
    static let startDateShortFormat = "startDateShortFormat"
    static let startTime = "startTime"
    static let score = "score"
    static let totalDistanceInMeters = "totalDistanceInMeters"
    static let secondsElapsed = "secondsElapsed"
    static let secondsPerMeter = "secondsPerMeter"
    
    /*
     startTime: NSDate?
     endTime: NSDate?
     secondsElapsed: Int16
     totalDistanceInMeters: Double
     secondsPerMeter: Double
     score: Int16
     runPoints: NSOrderedSet?
     owner: Owner?
     blocMembers: NSSet?
     */
    
    class func calculateScore(
        blocCount: Double,
        totalSeconds: Double,
        totalDistanceInMeters: Double,
        secondsPerMeter: Double)
        -> Int32 {
        
        let rateDifference = 0.260976 - 0.223694
        let totalRunners = blocCount + 1
        let rateScore = (rateDifference * 2 / secondsPerMeter) * 600
        let distanceScore = totalDistanceInMeters / 16.0
        let time = totalSeconds / (7.0 * 60.0)
        var score = Int32((totalRunners * (rateScore + distanceScore) * time))
        score = score - (score % 10)
        
        return score
    }
    
    class func create(
        owner: Owner,
        blocMembers: [BlocMember]? = nil,
        context: NSManagedObjectContext)
        throws -> Run? {
        
        var run: Run?
        
        context.performAndWait {
            run = NSEntityDescription.insertNewObject(
                forEntityName: Run.entityName,
                into: context) as? Run
            run?.startTime = NSDate()
            run?.endTime = NSDate()
            run?.secondsElapsed = 0
            run?.totalDistanceInMeters = 0
            run?.secondsPerMeter = 0
            run?.score = 0
            run?.owner = owner
            
            if let blocMembers = blocMembers,
                let mutableBlocMembers = run?.mutableSetValue(forKey: Run.blocMembers) {
                mutableBlocMembers.addObjects(from: blocMembers)
            }
        }
        
        try context.save()
        return run
    }
    
    func updateLocations(currentLocation: CLLocation) throws {
        let lastRunPoint = self.runPoints?.lastObject as? RunPoint
        
        let _ = try RunPoint.create(
            latitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude,
            run: self,
            lastRunPoint: lastRunPoint,
            context: self.managedObjectContext!)
    }
    
    func refreshBlocMembers(blocMembers: [BlocMember]) {
        let mutableBlocMembers = self.mutableSetValue(forKey: Run.blocMembers)
        mutableBlocMembers.removeAllObjects()
        mutableBlocMembers.addObjects(from: blocMembers)
    }
    
    func updateTimeElapsed() {
        if let lastRunPoint = self.runPoints?.lastObject as? RunPoint {
            self.endTime = lastRunPoint.timestamp
            
            if let start = self.startTime as? Date,
                let end = self.endTime as? Date {
                
                // update time elapsed (seconds)
                let calendar = NSCalendar(calendarIdentifier: .gregorian)
                let seconds = calendar?.components(
                    .second,
                    from: start,
                    to: end,
                    options: .matchStrictly).second
                
                self.secondsElapsed = Int16(seconds!)
            }
        }
    }
    
    func updateDistanceRateAndScore() {
        if let allRunPoints = self.runPoints?.array as? [RunPoint] {
            self.totalDistanceInMeters = allRunPoints.reduce(0) {
                return $0 + $1.metersFromLastPoint
            }
            
            if self.totalDistanceInMeters > 0 {
                let secondsDouble = Double(self.secondsElapsed)
                self.secondsPerMeter = secondsDouble / self.totalDistanceInMeters
                let blocCount = Double(self.blocMembers!.count)
                self.score = Run.calculateScore(
                    blocCount: blocCount,
                    totalSeconds: secondsDouble,
                    totalDistanceInMeters: self.totalDistanceInMeters,
                    secondsPerMeter: self.secondsPerMeter)
            
            } else {
                self.secondsPerMeter = 0
                self.score = 0
            }
        }
    }
    
    func update(
        currentLocation: CLLocation? = nil,
        blocMembers: [BlocMember]? = nil)
        throws {
        
        if let currentLocation = currentLocation {
            try updateLocations(currentLocation: currentLocation)
        }
        
        self.managedObjectContext?.performAndWait {
            if let blocMembers = blocMembers {
                self.refreshBlocMembers(blocMembers: blocMembers)
            }
            
            self.updateTimeElapsed()
            self.updateDistanceRateAndScore()
        }
        
        try self.managedObjectContext?.save()
    }
    
    func delete() throws {
        self.managedObjectContext?.delete(self)
        try self.managedObjectContext?.save()
    }
    
    var startDateShortFormat: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: startTime! as Date)
        }
    }
    
    class func sumScores(context: NSManagedObjectContext) -> Int32 {
        
        var amountTotal: Int32 = 0
        
        let expression = NSExpressionDescription()
        let expressionName = "amountTotal"
        expression.expression =  NSExpression(
            forFunction: "sum:",
            arguments: [NSExpression(forKeyPath: Run.score)])
        expression.name = expressionName
        expression.expressionResultType = NSAttributeType.integer32AttributeType
        
        let request: NSFetchRequest<NSFetchRequestResult> = Run.fetchRequest()
        request.propertiesToFetch = [expression]
        request.resultType = .dictionaryResultType
        
        do {
            let results = try context.fetch(request)
            
            if let resultMap = results.first as? [String: Int32] {
                amountTotal = resultMap[expressionName]!
            }
            
        } catch let error {
            print("Error when summing amounts: \(error.localizedDescription)")
        }
        
        return amountTotal
    }

}
