//
//  URL+Extensions.swift
//  eVgo
//
//  Created by Christophe Delhaze on 12/3/20.
//  Copyright © 2020 Christophe Delhaze. All rights reserved.
//

import Foundation

extension URL {
    
    static func apiURL() -> URL? {
        return URL(string: "https://developer.nrel.gov/api/alt-fuel-stations/v1.json?fuel_type=ELEC&limit=all&api_key=GCziNRFdaSthcOcALQKNFLIqDABSfkSkaCmIiKck&format=JSON&ev_network=eVgo%20Network")
    }
    
}
