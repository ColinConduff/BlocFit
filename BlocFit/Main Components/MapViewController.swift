//
//  MapViewController.swift
//  BlocFit
//
//  Created by Colin Conduff on 9/30/16.
//  Copyright © 2016 Colin Conduff. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    // unowned?
    var mapView: GMSMapView?
    
    weak var dashboardUpdateDelegate: DashboardControllerProtocol!
    
    var controller: MapControllerProtocol! {
        didSet {
            controller.authStatusDidChange = { [unowned self] controller in
                self.mapView?.isMyLocationEnabled = controller.authStatusIsAuthAlways
                self.alertUserIfLocationServices(areDisabled: !controller.authStatusIsAuthAlways)
            }
            controller.cameraPositionDidChange = { [unowned self] controller in
                self.mapView?.camera = controller.cameraPosition
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
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: controller.cameraPosition)
        mapView!.isMyLocationEnabled = controller.authStatusIsAuthAlways
        view = mapView
    }
    
    override func viewDidLayoutSubviews() {
        controller.cameraPositionNeedsUpdate()
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
    
    // Called if location auth status is not authorized always
    func alertUserIfLocationServices(areDisabled disabled: Bool) {
        guard disabled else { return }
        
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please authorize BlocFit to access your location.",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
