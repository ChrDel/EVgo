//
//  EVgoLocationAPI.swift
//  eVgo
//
//  Created by Christophe Delhaze on 12/3/20.
//  Copyright © 2020 Christophe Delhaze. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa

struct EVgoLocationsAPI {
    
    static let disposeBag = DisposeBag()
    
    static func loadEVgoLocations() -> Driver<[EVgoPointAnnotation]>{
        guard let url = URL.apiURL() else {
            return (Observable.just([EVgoPointAnnotation]()))
                .asDriver(onErrorJustReturn: [EVgoPointAnnotation]())
        }
        
        let resource = Resource<EVgoStations>(url: url)
        
        return URLRequest.load(resource: resource)
            .observeOn(MainScheduler.instance)
            .retry(3)
            .catchError { error in
                print(error.localizedDescription)
                return Observable.just(EVgoStations.empty)
        }.asDriver(onErrorJustReturn: EVgoStations.empty)
            .map { stations -> [EVgoPointAnnotation] in
                stations.fuel_stations.map { (station) -> EVgoPointAnnotation in
                    let annotation = EVgoPointAnnotation()
                    annotation.title = station.station_name
                    annotation.ev_dc_fast_num = station.ev_dc_fast_num ?? 0
                    annotation.coordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude)
                    return annotation
                }
        }
        
    }
    
}
