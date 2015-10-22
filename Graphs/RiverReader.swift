//
//  GraphReader.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 12/2/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import MapKit

class RiverReader {
    
    class func readRiver() -> [MKPolyline] {
        
        let path = NSBundle.mainBundle().pathForResource("rivers", ofType: "txt")!
        let text = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        
        let lines: [String] = text.componentsSeparatedByString("\n")
        
        var list: [MKPolyline] = []
        
        for line in lines {
            let split = line.componentsSeparatedByString(";")
            let value = Int(split[0])!
            let coordinatesString = split[1].componentsSeparatedByString(" ")
            var coordinates: [CLLocationCoordinate2D] = []
            for coordinate in coordinatesString {
                let coordinateComponents = coordinate.componentsSeparatedByString(",")
                let longitude: Double = (coordinateComponents[0] as NSString).doubleValue
                let latitude: Double = (coordinateComponents[1] as NSString).doubleValue
                coordinates.append( CLLocationCoordinate2DMake(latitude, longitude) )
                
            }
            var polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            polyline.title = "river:\(value)"
            list.append(polyline)
            //println("\(polyline.coordinate.latitude),\(polyline.coordinate.longitude)")
        }
        //println(list.count)
        return list
    }
}