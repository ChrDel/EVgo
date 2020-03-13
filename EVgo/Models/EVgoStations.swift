//
//  EVgoStations.swift
//  eVgo
//
//  Created by Christophe Delhaze on 12/3/20.
//  Copyright © 2020 Christophe Delhaze. All rights reserved.
//

struct EVgoStations: Decodable {
    let fuel_stations: [EVgoStation]
}

extension EVgoStations {
    static var empty: EVgoStations {
        return EVgoStations(fuel_stations: [])
    }
}

struct EVgoStation: Decodable {
    let station_name: String
    let latitude: Double
    let longitude: Double
    let ev_connector_types: [String]
    let ev_dc_fast_num: Int?
}
