//
//  MapController.swift
//  BlocFit
//
//  Created by Colin Conduff on 1/8/17.
//  Copyright © 2017 Colin Conduff. All rights reserved.
//

import CoreData
import GoogleMaps
import HealthKit

protocol MapNotificationDelegate: class {
    func blocMembersDidChange(_ blocMembers: [BlocMember])
    func didPressActionButton() -> Bool
    func loadSavedRun(run: Run)
}

protocol MapControllerProtocol: class {
    
    var mapRunModel: MapRunModel { get }
    var authStatusIsAuthAlways: Bool { get }
    var cameraPosition: GMSCameraPosition { get }
    var paths: [Path] { get }
    var run: Run? { get }
    var seconds: Int { get }
    
    var mapRunModelDidChange: ((MapRunModel) -> ())? { get set }
    var authStatusDidChange: ((MapControllerProtocol) -> ())? { get set }
    var cameraPositionDidChange: ((MapControllerProtocol) -> ())? { get set }
    var pathsDidChange: ((MapControllerProtocol) -> ())? { get set }
    var secondsDidChange: ((MapControllerProtocol) -> ())? { get set }
    
    init(requestMainDataDelegate: RequestMainDataDelegate, scoreReporterDelegate: ScoreReporterDelegate, context: NSManagedObjectContext)
    
    func cameraPositionNeedsUpdate()
}

class MapController: NSObject, CLLocationManagerDelegate, MapControllerProtocol, MapNotificationDelegate {
    
    var mapRunModel: MapRunModel { didSet { self.mapRunModelDidChange?(mapRunModel) } }
    var authStatusIsAuthAlways = false { didSet { self.authStatusDidChange?(self) } }
    var cameraPosition: GMSCameraPosition { didSet { self.cameraPositionDidChange?(self) } }
    var paths = [Path]() { didSet { self.pathsDidChange?(self) } }
    var seconds = 0 { didSet { self.secondsDidChange?(self) } }
    var run: Run? {
        didSet {
            guard let run = run else { return }
            self.setDashboardModel(using: run)
        }
    }
    
    var mapRunModelDidChange: ((MapRunModel) -> ())?
    var authStatusDidChange: ((MapControllerProtocol) -> ())?
    var cameraPositionDidChange: ((MapControllerProtocol) -> ())?
    var pathsDidChange: ((MapControllerProtocol) -> ())?
    var secondsDidChange: ((MapControllerProtocol) -> ())?
    
    weak var requestMainDataDelegate: RequestMainDataDelegate!
    weak var scoreReporterDelegate: ScoreReporterDelegate!
    
    let locationManager = CLLocationManager()
    
    let context: NSManagedObjectContext
    let owner: Owner
    
    var currentlyRunning = false
    var timer = Timer()
    
    required init(requestMainDataDelegate: RequestMainDataDelegate,
                  scoreReporterDelegate: ScoreReporterDelegate,
                  context: NSManagedObjectContext) {
        
        self.requestMainDataDelegate = requestMainDataDelegate
        self.scoreReporterDelegate = scoreReporterDelegate
        self.context = context
        owner = try! Owner.get(context: context)!
        
        mapRunModel = MapRunModel(secondsElapsed: 0,
                                  score: 0,
                                  totalDistanceInMeters: 0,
                                  secondsPerMeter: 0)
        
        cameraPosition = GMSCameraPosition.camera(withLatitude: 37.35,
                                                  longitude: -122.0,
                                                  zoom: 18.0)
        
        authStatusIsAuthAlways = CLLocationManager.authorizationStatus() == .authorizedAlways
        
        super.init()
        initializeLocationManagement()
        HealthKitManager.authorize()
    }
    
    private func initializeLocationManagement() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    // CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        authStatusIsAuthAlways = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error")
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        var paths = [Path]()
        
        for location in locations {
            if location.horizontalAccuracy < 20 {
                
                let lastRunPoint = run?.runPoints?.lastObject as? RunPoint
                
                updateRun(currentLocation: location)
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                if let lastLatitude = lastRunPoint?.latitude,
                    let lastLongitude = lastRunPoint?.longitude {
                    
                    let path = Path(fromLat: lastLatitude,
                                    fromLong: lastLongitude,
                                    toLat: latitude,
                                    toLong: longitude)
                    paths.append(path)
                }
                
                updateCameraPosition(latitude: latitude, longitude: longitude)
            }
        }
        
        self.paths = paths
    }
    
    func cameraPositionNeedsUpdate() {
        if let coordinate = locationManager.location?.coordinate {
            updateCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    private func updateCameraPosition(latitude: Double, longitude: Double) {
        let target = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        cameraPosition = GMSCameraPosition.camera(withTarget: target, zoom: 18.0)
    }
    
    // MapNotificationDelegate Method
    
    func loadSavedRun(run: Run) {
        
        self.run = run
        guard let runPoints = run.runPoints?.array as? [RunPoint] else { return }
        var paths = [Path]()
        var lastRunPoint: RunPoint? = nil
        
        for runPoint in runPoints {
            if let lastRunPoint = lastRunPoint {
                let path = Path(fromLat: lastRunPoint.latitude,
                                fromLong: lastRunPoint.longitude,
                                toLat: runPoint.latitude,
                                toLong: runPoint.longitude)
                paths.append(path)
            }
            
            lastRunPoint = runPoint
        }
        
        self.paths = paths
        
        if let latitude = lastRunPoint?.latitude,
            let longitude = lastRunPoint?.longitude {
            updateCameraPosition(latitude: latitude, longitude: longitude)
        }
    }
    
    private func updateRun(currentLocation: CLLocation) {
        guard let run = run else { return }
        try? run.update(currentLocation: currentLocation)
        setDashboardModel(using: run)
    }
    
    private func setDashboardModel(using run: Run) {
        mapRunModel = MapRunModel(secondsElapsed: Double(run.secondsElapsed),
                                  score: Int(run.score),
                                  totalDistanceInMeters: run.totalDistanceInMeters,
                                  secondsPerMeter: run.secondsPerMeter)
    }
    
    // MapNotificationDelegate Method
    func blocMembersDidChange(_ blocMembers: [BlocMember]) {
        guard let run = run else { return }
        try? run.update(blocMembers: blocMembers)
    }
    
    // Logic for responding to action button click //
    
    // MapNotificationDelegate Method
    func didPressActionButton() -> Bool {
        
        if authStatusIsAuthAlways {
            if currentlyRunning {
                stopRunning()
            } else {
                startRunning()
            }
            
            currentlyRunning = !currentlyRunning
        } else {
            authStatusIsAuthAlways = false // trigger didSet
        }
        
        return authStatusIsAuthAlways
    }
    
    private func startRunning() {
        let blocMembers = requestMainDataDelegate.getCurrentBlocMembers()
        run = try! Run.create(owner: owner, blocMembers: blocMembers, context: context)
        startTrackingData()
    }
    
    private func startTrackingData() {
        locationManager.startUpdatingLocation()
        seconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.seconds += 1 }
    }
    
    private func stopRunning() {
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        
        if let run = run {
            saveRunToHealthKit(run)
            
            scoreReporterDelegate.submitScore(run: run)
            scoreReporterDelegate.submitScore(owner: owner)
        }
    }
    
    private func saveRunToHealthKit(_ run: Run) {
        guard let start = run.startTime as? Date,
            let end = run.endTime as? Date else { return }
        
        HealthKitManager.save(meters: run.totalDistanceInMeters,
                              start: start,
                              end: end)
    }
}
