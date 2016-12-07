//
//  MapViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 9/30/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import HealthKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var mapView: GMSMapView?
    let locationManager = CLLocationManager()
    
    weak var mapDashboardDelegate: MapDashboardDelegate?
    weak var mainVCDataDelegate: RequestMainDataDelegate?
    weak var scoreReporterDelegate: ScoreReporterDelegate?
    
    var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var owner: Owner?
    var run: Run?
    
    var currentlyRunning = false
    var clLocations = [CLLocation]()
    var totalDistance = 0.0
    var timer = Timer()
    var seconds = 0
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 37.35, longitude: -122.0, zoom: 8.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        let authStatus = CLLocationManager.authorizationStatus()
        mapView!.isMyLocationEnabled = (authStatus == .authorizedAlways)
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.requestAlwaysAuthorization()
        
        if let context = context,
            let owner = try? Owner.get(context: context) {
            self.owner = owner
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HealthKitManager.authorize()
    }
    
    override func viewDidLayoutSubviews() {
        // move map camera to current location
        if let coordinate = locationManager.location?.coordinate {
            let target = CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude)
            mapView!.camera = GMSCameraPosition.camera(withTarget: target, zoom: 18.0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateTimer() {
        seconds += 1
        mapDashboardDelegate?.setTimeLabel(totalSeconds: Double(seconds))
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            if location.horizontalAccuracy < 20 {
                
                // should be asynchronous 
                // however may mess up order of run points
                updateRun(currentLocation: location)
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                if let lastLocation = clLocations.last {
                    let lastLatitude = lastLocation.coordinate.latitude
                    let lastLongitude = lastLocation.coordinate.longitude
                    
                    drawPath(
                        fromLatitude: lastLatitude,
                        fromLongitude: lastLongitude,
                        toLatitude: latitude,
                        toLongitude: longitude)
                }
                
                let target = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView!.camera = GMSCameraPosition.camera(withTarget: target, zoom: 18.0)
                clLocations.append(location)
            }
        }
    }
    
    func drawPath(
        fromLatitude: CLLocationDegrees,
        fromLongitude: CLLocationDegrees,
        toLatitude: CLLocationDegrees,
        toLongitude: CLLocationDegrees) {
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: fromLatitude, longitude: fromLongitude))
        path.add(CLLocationCoordinate2D(latitude: toLatitude, longitude: toLongitude))
        
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView!
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapView?.isMyLocationEnabled = (status == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error")
        print(error)
    }
    
    func didPressActionButton() {
        if currentlyRunning {
            stopTrackingData()
            saveRunToHealthKit()
            
            if let run = run,
                let owner = owner,
                let scoreReporterDelegate = scoreReporterDelegate {
                
                scoreReporterDelegate.submitScore(run: run)
                scoreReporterDelegate.submitScore(owner: owner)
            }
        
        } else {
            let blocMembers = mainVCDataDelegate!.getCurrentBlocMembers()
            startNewRun(blocMembers: blocMembers)
            startTrackingData()
        }
        
        currentlyRunning = !currentlyRunning
    }
    
    func updateDashboard(run: Run) {
        mapDashboardDelegate?.setRateLabel(
            seconds: Double(run.secondsElapsed),
            distance: run.totalDistanceInMeters)
        mapDashboardDelegate?.setDistanceLabel(newDistance: run.totalDistanceInMeters)
        mapDashboardDelegate?.setScoreLabel(newScore: Int(run.score))
    }
    
    func startTrackingData() {
        locationManager.startUpdatingLocation()
        clLocations = [CLLocation]()
        totalDistance = 0.0
        seconds = 0
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.updateTimer),
            userInfo: nil,
            repeats: true)
    }
    
    func stopTrackingData() {
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    func saveRunToHealthKit() {
        if let run = self.run,
            let start = run.startTime as? Date,
            let end = run.endTime as? Date {
            
            HealthKitManager.save(
                meters: run.totalDistanceInMeters,
                start: start,
                end: end)
        }
    }
    
    func startNewRun(blocMembers: [BlocMember]) {
        if let run = try? Run.create(owner: owner!, blocMembers: blocMembers, context: context!) {
            self.run = run
        }
    }
    
    func updateCurrentRunWith(blocMembers: [BlocMember]) {
        // update the current run if currentBlocMembers changes
        // called from mainViewController
        updateRun(blocMembers: blocMembers)
    }
    
    func updateRun(
        currentLocation: CLLocation? = nil,
        blocMembers: [BlocMember]? = nil) {
        
        do {
            if let run = run {
                try run.update(currentLocation: currentLocation, blocMembers: blocMembers)
                try owner?.updateScore()
                updateDashboard(run: run)
            }
        } catch let error {
            print(error)
        }
    }
    
    func loadSavedRun(run: Run) {
        
        updateDashboard(run: run)
        
        if let runPoints = run.runPoints?.array as? [RunPoint] {
            var lastRunPoint: RunPoint? = nil
            
            for runPoint in runPoints {
                if let lastRunPoint = lastRunPoint {
                    drawPath(
                        fromLatitude: lastRunPoint.latitude,
                        fromLongitude: lastRunPoint.longitude,
                        toLatitude: runPoint.latitude,
                        toLongitude: runPoint.longitude)
                }
                
                lastRunPoint = runPoint
            }
            
            if let latitude = lastRunPoint?.latitude,
                let longitude = lastRunPoint?.longitude {
                let target = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude)
                mapView!.camera = GMSCameraPosition.camera(
                    withTarget: target,
                    zoom: 18.0)
            }
        }
    }
}
