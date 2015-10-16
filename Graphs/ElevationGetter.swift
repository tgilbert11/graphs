//
//  ElevationGetter.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 1/1/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import MapKit

class ElevationGetter {
    class func getElevation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Double? {
        
        let urlString = String("http://ned.usgs.gov/epqs/pqs.php?x=\(longitude)&y=\(latitude)&units=FEET&output=xml")
        //println(urlString)
        let url = NSURL(string: urlString)
        //println( NSString(contentsOfURL: url!, usedEncoding: nil, error: nil) )
        let outputString = NSString(contentsOfURL: url!, usedEncoding: nil, error: nil) as String
        let firstSplit = outputString.componentsSeparatedByString("<Elevation>")
        let secondSplit = firstSplit[1].componentsSeparatedByString("</Elevation>")
        let elevation = (secondSplit[0] as NSString).doubleValue
        return elevation
        
    }
}