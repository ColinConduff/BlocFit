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

class MapViewController: UIViewController {
    
    // unowned?
    var mapView: GMSMapView? // unnecessary?
    
    weak var dashboardUpdateDelegate: DashboardControllerProtocol!
    
    var controller: MapControllerProtocol! {
        didSet {
            controller.authStatusDidChange = { [unowned self] controller in
                self.mapView?.isMyLocationEnabled = controller.authStatusIsAuthAlways
            }
            controller.cameraPositionDidChange = { [unowned self] controller in
                if let cameraPosition = controller.cameraPosition {
                    self.mapView?.camera = cameraPosition
                }
            }
            controller.pathsDidChange = { [unowned self] controller in
                for path in controller.paths {
                    self.drawPath(fromLatitude: path.fromLat,
                             fromLongitude: path.fromLong,
                             toLatitude: path.toLat,
                             toLongitude: path.toLong)
                }
            }
            controller.mapRunModelDidChange = { [unowned self] model in
                // view should not interact with the model directly?
                self.dashboardUpdateDelegate.update(totalSeconds: model.secondsElapsed)
                self.dashboardUpdateDelegate.update(score: model.score)
                self.dashboardUpdateDelegate.update(meters: model.totalDistanceInMeters,
                                               secondsPerMeter: model.secondsPerMeter)
            }
            controller.secondsDidChange = { [unowned self] controller in
                self.dashboardUpdateDelegate.update(totalSeconds: Double(controller.seconds))
            }
        }
    }
    
    override func loadView() {
        
        // move to controller
        // controller may not be created yet
        let camera = GMSCameraPosition.camera(withLatitude: 37.35, longitude: -122.0, zoom: 8.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        let authStatus = CLLocationManager.authorizationStatus()
        mapView!.isMyLocationEnabled = (authStatus == .authorizedAlways)
        view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HealthKitManager.authorize() // move to controller
    }
    
    override func viewDidLayoutSubviews() {
        controller.setInitialCameraPosition()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func drawPath(fromLatitude: CLLocationDegrees,
                  fromLongitude: CLLocationDegrees,
                  toLatitude: CLLocationDegrees,
                  toLongitude: CLLocationDegrees) {
        
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: fromLatitude, longitude: fromLongitude))
        path.add(CLLocationCoordinate2D(latitude: toLatitude, longitude: toLongitude))
        
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView!
    }
}
