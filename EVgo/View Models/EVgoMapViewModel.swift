//
//  EVgoMapViewModel.swift
//  eVgo
//
//  Created by Christophe Delhaze on 12/3/20.
//  Copyright © 2020 Christophe Delhaze. All rights reserved.
//

import MapKit
import RxSwift
import RxMKMapView
import RxCoreLocation

class EVgoMapViewModel: NSObject {
    
    /// user to request location authorization to display the user current location
    let locationManager =  CLLocationManager()
    
    weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    
    init(mapView: MKMapView) {
        super.init()
        self.mapView = mapView
        requestLocationAuthorization()
        setupMapBindings()
    }
    
}

//MARK: CoreLocation bindings and functions
extension EVgoMapViewModel {
    
    func setupLocationManagerBindings() {
        locationManager.rx.didChangeAuthorization
            .filter { (manager, status) -> Bool in
                status == .authorizedAlways || status == .authorizedWhenInUse
        }
        .take(1)
        .subscribe({ [weak self] _ in
            self?.loadEVgoLocations()
        })
        .disposed(by: disposeBag)
    }
    
    func requestLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: loadEVgoLocations()
        default: UIAlertController.showAlert(with: "Warning...", message: "Unable to access your location.")
        }
        
    }
    
}

//MARK: MapView Delegate and bindings
extension EVgoMapViewModel: MKMapViewDelegate {
    
    fileprivate func setupMapBindings() {
        
        /// Required for custom annotations
        mapView.delegate = self
        
        mapView.rx.didUpdateUserLocation
            .take(1)
            .subscribe(onNext: { [weak self] (userLocation) in
                self?.centerMap(on: userLocation)
            })
            .disposed(by: disposeBag)
        
    }
    
    func centerMap(on userLocation: MKUserLocation) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let clusterAnnotation = EVgoClusterAnnotation(memberAnnotations: memberAnnotations)
        clusterAnnotation.ev_dc_fast_num = memberAnnotations.reduce(into: 0, { (sum, annotation) in
            if let ev_dc_fast_num = (annotation as? EVgoPointAnnotation)?.ev_dc_fast_num {
                sum += ev_dc_fast_num
            }
        })
        return clusterAnnotation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? EVgoPointAnnotation ?? annotation as? EVgoClusterAnnotation else { return  nil }
        
        let reuseIdentifier = annotation is EVgoClusterAnnotation ? "MKClusterAnnotation" : "EVgoPointAnnotation"
        
        var annotationView: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            as? MKMarkerAnnotationView {
            dequeuedView.glyphText = (annotation.value(forKey: "ev_dc_fast_num") != nil) ? "\(annotation.value(forKey: "ev_dc_fast_num")!)" : nil
            dequeuedView.annotation = annotation as? MKAnnotation
            annotationView = dequeuedView
        } else {
            annotationView = MKMarkerAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: reuseIdentifier)
            annotationView.canShowCallout = true
            annotationView.glyphText = (annotation.value(forKey: "ev_dc_fast_num") != nil) ? "\(annotation.value(forKey: "ev_dc_fast_num")!)" : nil
            annotationView.markerTintColor = UIColor(displayP3Red: 47/255, green: 118/255, blue: 51/255, alpha: 1)
            annotationView.clusteringIdentifier = "EVgo Station"
        }
        
        return annotationView

    }
    
    fileprivate func loadEVgoLocations() {
        EVgoLocationsAPI.loadEVgoLocations()
        .asDriver(onErrorJustReturn: [EVgoPointAnnotation]())
        .drive(mapView.rx.annotations)
        .disposed(by: disposeBag)
    }
    
}
