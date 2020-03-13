//
//  EVgoMapViewController.swift
//  eVgo
//
//  Created by Christophe Delhaze on 12/3/20.
//  Copyright © 2020 Christophe Delhaze. All rights reserved.
//

import MapKit

class EVgoMapViewController: UIViewController {
    
    ///
    private var evGoMapViewModel: EVgoMapViewModel!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        evGoMapViewModel = EVgoMapViewModel(mapView: mapView)
    }
    
}
