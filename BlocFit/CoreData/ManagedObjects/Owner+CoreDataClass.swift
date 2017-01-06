//
//  Owner+CoreDataClass.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

public class Owner: NSManagedObject {
    
    static let OWNER = "Owner"
    
    class func wasCreated(context: NSManagedObjectContext) throws -> Bool {
        let request: NSFetchRequest<Owner> = Owner.fetchRequest()
        let count = try context.count(for: request)
        return count > 0
    }
    
    class func get(context: NSManagedObjectContext) throws -> Owner? {
        let request: NSFetchRequest<Owner> = Owner.fetchRequest()
        return try context.fetch(request).first
    }
    
    class func create(context: NSManagedObjectContext) throws -> Owner? {
        var owner: Owner?
        
        context.performAndWait {
            owner = NSEntityDescription.insertNewObject(
                forEntityName: Owner.OWNER,
                into: context) as? Owner
            
            owner?.username = RandomNameGenerator.getRandomName()
            owner?.totalScore = 0
        }
        
        try context.save()
        return owner
    }
    
    func updateScore() throws {
        if let context = self.managedObjectContext {
            
            context.perform {
                self.totalScore = Run.sumScores(context: context)
            }
        
            try context.save()
        }
    }
}
