//
//  BlocMember+CoreDataClass.swift
//  BlocFit
//
//  Created by Colin Conduff on 10/1/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData

public class BlocMember: NSManagedObject {
    
    static let entityName = "BlocMember"
    static let trusted = "trusted"
    static let username = "username"
    
    class func get(
        username: String,
        context: NSManagedObjectContext)
        throws -> BlocMember? {
            
        let request: NSFetchRequest<BlocMember> = BlocMember.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "username = %@", username)
            
        return try context.fetch(request).first
    }
    
    class func create(
        username: String,
        totalScore: Int32,
        firstname: String?,
        context: NSManagedObjectContext)
        throws -> BlocMember? {
            
        var blockMember: BlocMember?
            
        context.perform {
            blockMember = NSEntityDescription.insertNewObject(
                forEntityName: BlocMember.entityName,
                into: context) as? BlocMember
            
            blockMember?.username = username
            blockMember?.totalScore = totalScore
            blockMember?.firstname = firstname
            
            // User Default setting
            blockMember?.trusted = BFUserDefaults.getNewFriendDefaultTrustedSetting()
        }
            
        try context.save()
            
        return blockMember
    }
    
    func update(totalScore: Int32? = nil, trusted: Bool? = nil) throws {
            
        self.managedObjectContext?.perform {
            if let totalScore = totalScore {
                self.totalScore = totalScore
            }
            if let trusted = trusted {
                self.trusted = trusted
            }
        }
            
        try self.managedObjectContext?.save()
    }
    
    func update(firstname: String?) throws {
            
            self.managedObjectContext?.perform {
                self.firstname = firstname
            }
            
            try self.managedObjectContext?.save()
    }
    
    func delete() throws {
        self.managedObjectContext?.delete(self)
        try self.managedObjectContext?.save()
    }
}
