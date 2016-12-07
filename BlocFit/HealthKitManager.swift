//
//  HealthKitManager.swift
//  BlocFit
//
//  Created by Colin Conduff on 11/9/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import Foundation
import HealthKit

struct HealthKitManager {
    
    static let store = HKHealthStore() 
    
    static func authorize() {
        
        if HKHealthStore.isHealthDataAvailable() {
        
            let healthDataToWrite: Set = [
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ]
            
            store.requestAuthorization(toShare: healthDataToWrite, read: nil) {
                (success, error) in
                
                if success {
                    preferredUnits(hkQuantityTypes: healthDataToWrite)
                }
            }
        }
    }
    
    static func preferredUnits(hkQuantityTypes: Set<HKQuantityType>) {
        
        // Only get the preferred units upon initial set up
        if UserDefaults.standard.object(forKey: BFUserDefaults.unitSetting) == nil {
            
            store.preferredUnits(for: hkQuantityTypes) { (unitDict, error) in
                if let distanceType = hkQuantityTypes.first,
                    let unitString = unitDict[distanceType]?.unitString,
                    unitString != "mi" {
                    BFUserDefaults.set(isImperial: false)
                } else {
                    BFUserDefaults.set(isImperial: true)
                }
            }
        }
    }
    
    static func save(meters: Double, start: Date, end: Date) {
        
        if let distanceType = HKQuantityType.quantityType(
            forIdentifier: .distanceWalkingRunning),
            
            store.authorizationStatus(for: distanceType) == .sharingAuthorized &&
            HKHealthStore.isHealthDataAvailable() {
            
            let distanceQuantity = HKQuantity(
                unit: HKUnit.meter(),
                doubleValue: meters)
            
            let sample = HKQuantitySample(
                type: distanceType,
                quantity: distanceQuantity,
                start: start,
                end: end)
            
            store.save(sample) { (success, error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
}
