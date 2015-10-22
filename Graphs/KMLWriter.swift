//
//  KMLWriter.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 12/3/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class KMLWriter {
    
    class func KMLForEntireGraph(graph: Graph, clean: Bool) {
        //  KML
        var KML = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        //  Waypoints
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        KML += "Waypoints"
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderOpen", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        
        let waypointTypes = ["Camp", "Picnic", "Parking", "POI", "Junction"]
        
        for type in waypointTypes {
            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
            KML += type
            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding)
            
            for node in graph.nodes {
                if node.type == type {
                    KML += KMLForNode(node, visible: type == "Junction" ? false : true)
                }
            }
            
            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        }
        
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        //  Trails
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        KML += "Trails"
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        var trailUsed: Dictionary<String, Bool> = Dictionary()
        // Each node...
        for node in graph.nodes {
            for edge in node.edges {
                
                if trailUsed[edge.name] == nil {
                    // new trail! fill out the entire trail
                    
                    if clean {
                        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                        KML += edge.name
                        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2White", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                    }
                    
                    var coordinateString = ""
                    var segmentNumber = 1
                    var trailComplete = false
                    while !trailComplete {
                        var segmentFound = false
                        for searchNode in graph.nodes {
                            for searchEdge in searchNode.edges {
                                if !segmentFound {
                                    if searchEdge.name == edge.name && searchEdge.segment == segmentNumber {
                                        if clean {
                                            coordinateString += CoordinatesForEdge(searchEdge, forward: true)
                                        }
                                        else {
                                            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                                            KML += String("\(searchEdge.name),\(searchEdge.segment)")
                                            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2White", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                                            KML += CoordinatesForEdge(searchEdge, forward: true)
                                            KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                                        }
                                        segmentNumber += 1
                                        segmentFound = true
                                    }
                                }
                            }
                        }
                        if !segmentFound {
                            trailComplete = true
                        }
                    }
                    
                    if clean {
                        KML += coordinateString
                        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
                    }
                    
                    trailUsed[edge.name] = true
                }
                
            }
        }
        
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        //  end of KML
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        try! KML.writeToFile("/Users/taylorg/Local Reference/Graphs/Graphs/graph.kml", atomically: true, encoding:NSUTF8StringEncoding)
    }   
    
    class func writeKML(route: Route, pathOnly: Bool) {
        
        var content: String = KMLForRoute(route, pathOnly: pathOnly)
        try! content.writeToFile("/Users/taylorg/Local Reference/Graphs/Graphs/output.kml", atomically: true, encoding:NSUTF8StringEncoding)
    }
    
    class func KMLForRoute(route: Route, pathOnly: Bool) -> String {
        
        var KML = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        var pathCoordinates = ""
        let pathName = "Your Route"
        
        var currentNode: Node = route.startingNode
        for edge in route.edges {
            if !pathOnly {
                KML += KMLForNode(currentNode, visible: true)
            }
            if edge.head == currentNode {
                currentNode = edge.tail
                pathCoordinates += CoordinatesForEdge(edge, forward: false)
                pathCoordinates += " "
            }
            else {
                currentNode = edge.head
                pathCoordinates += CoordinatesForEdge(edge, forward: true)
            }
        }
        KML += KMLForPath(pathName, pathCoordinates: pathCoordinates);
        if !pathOnly {
            KML += KMLForNode(currentNode, visible: true)
        }
        
        KML += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        return KML
    }
    
    class func KMLForNode (node: Node, visible: Bool) -> String {
        var header = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        if !visible {
            header += try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("Invisible", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        }
        let section2 = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let name = node.name
        
        let section3 = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection3", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let coordinateString = "\(node.coordinate.longitude),\(node.coordinate.latitude),0 "
        
        let section4 = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection4", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        var placemarkStyleString: String = ""
        switch (node.type) {
        case "Camp":
            placemarkStyleString = "#msn_campground6"
        case "Junction":
            placemarkStyleString = "#msn_placemark_circle"
        case "Parking":
            placemarkStyleString = "#msn_parking_lot"
        case "Picnic":
            placemarkStyleString = "#msn_picnic"
        case "POI":
            placemarkStyleString = "#msn_open-diamond"
        default:
            placemarkStyleString = ""
        }
        
        let footer = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        return String("\(header)\(section2)\(name)\(section3)\(placemarkStyleString)\(section4)\(coordinateString)\(footer)")
    }
    
    class func CoordinatesForEdge (edge: Edge, forward: Bool) -> String {
        
        var coordinateString = ""
        
        if forward {
            for coordinate in edge.coordinates {
                coordinateString += "\(coordinate.longitude),\(coordinate.latitude),0 "
            }
        }
        else {
            for i in 0...edge.coordinates.count-1 {
                coordinateString += "\(edge.coordinates[edge.coordinates.count-1-i].longitude),\(edge.coordinates[edge.coordinates.count-1-i].latitude),0 "
            }
        }
        
        return coordinateString
    }
    
    class func KMLForPath(pathName: String, pathCoordinates: String) -> String {
        let header = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let name = pathName
        let section2 = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2Blue", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let coordinateString = pathCoordinates
        let footer = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        
        return String("\(header)\(name)\(section2)\(coordinateString)\(footer)")
    }
    
    
}