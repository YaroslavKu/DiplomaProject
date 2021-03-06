//
//  HealthKitManager.swift
//  watchOSApp WatchKit Extension
//
//  Created by Yaroslav Kukhar on 18.05.2022.
//

import Foundation
import Firebase
import HealthKit

class HealthKitManager {
    
    // Singleton
    public static var shared = HealthKitManager()
    private init() {}
    
    
    private let healthStore = HKHealthStore()
    private let ref = Database.database().reference()
    
    func authorizeHealthKit() {
        let read = Set([
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!
        ])
        
        let share = Set([
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!
        ])
        
        healthStore.requestAuthorization(toShare: read, read: share) { success, error in
            if success {
                print("HKHealthStore: Permition granted!")
                self.bgDelivery()
            } else {
                print("HKHealthStore: Permition denied!")
            }
        }
    }
    
    func bgDelivery() {
        heartRateBgDelivery()
        stepsCountBgDelivery()
    }

}

// MARK: Privates
private extension HealthKitManager {
    func getLatestHeartRate() {
        guard let sanlpeType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescription = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sanlpeType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescription]) { [self] sample, result, error in
            guard error == nil else {
                return
            }
            
            if let data = result?[0] as? HKQuantitySample {
                let unit = HKUnit(from: "count/min")
                let latestHeartRate = data.quantity.doubleValue(for: unit)
                
                print("#$ \(latestHeartRate)")
                self.sendPatientHeartRate(value: latestHeartRate)
            }

        }
        
        healthStore.execute(query)
    }
    
    func getLatestStepsCount() {
        guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else { return }
        
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: sampleType,
                                                quantitySamplePredicate: predicate,
                                                anchorDate: startDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, result, error in
            if let res = result {
                res.enumerateStatistics(from: startDate, to: Date()) { (statistic, value) in
                    if let count = statistic.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.count())
                        print(val)
                        self.sendPatientStepsCount(value: Int(val))
                    }
                    
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func heartRateBgDelivery() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let query = HKObserverQuery(sampleType: heartRateType, predicate: predicate) { query, completionHandler, errorOrNil in
            
            if errorOrNil != nil { return }
            self.getLatestHeartRate()
        }
        
        healthStore.execute(query)
    }
    
    func stepsCountBgDelivery() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { query, completionHandler, errorOrNil in
            
            if errorOrNil != nil {
                return
                
            }
            self.getLatestStepsCount()
        }
        
        healthStore.execute(query)
    }
}

// MARK: Networking
private extension HealthKitManager {
    func sendPatientHeartRate(value: Double) {
        if let supervisorUid = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.supervisorUid),
           let patientId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.patientId) {
            ref.child("users/\(supervisorUid)/patients/\(patientId)/heartRate").setValue(value)
        }
    }
    
    func sendPatientStepsCount(value: Int) {
        if let supervisorUid = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.supervisorUid),
           let patientId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.patientId) {
            ref.child("users/\(supervisorUid)/patients/\(patientId)/stepsCount").setValue(value)
        }
    }
}
