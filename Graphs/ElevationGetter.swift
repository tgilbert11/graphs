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
        guard let url = NSURL(string: urlString) else { return nil }
        //println( NSString(contentsOfURL: url!, usedEncoding: nil, error: nil) )
        
        var outputString = ""
        var didSucceed = false
        NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: {
            
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if data != nil && response != nil && response!.isKindOfClass(NSHTTPURLResponse) && (response! as! NSHTTPURLResponse).statusCode == 200 {
                outputString = String(data: data!, encoding:NSUTF8StringEncoding)!
                didSucceed = true
            }
        }).resume()
        
        if (didSucceed) {
            let firstSplit = outputString.componentsSeparatedByString("<Elevation>")
            let secondSplit = firstSplit[1].componentsSeparatedByString("</Elevation>")
            let elevation = (secondSplit[0] as NSString).doubleValue
            return elevation
        }
        else {
            return nil
        }
        
    }
}