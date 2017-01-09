//
//  Path.swift
//  BlocFit
//
//  Created by Colin Conduff on 1/8/17.
//  Copyright © 2017 Colin Conduff. All rights reserved.
//

import Foundation

struct Path {
    let fromLat: Double
    let fromLong: Double
    let toLat: Double
    let toLong: Double
    
    init(fromLat: Double, fromLong: Double, toLat: Double, toLong: Double) {
        self.fromLat = fromLat
        self.fromLong = fromLong
        self.toLat = toLat
        self.toLong = toLong
    }
}
