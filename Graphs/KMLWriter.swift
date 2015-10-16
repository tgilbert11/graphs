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
        var KML = String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        //  Waypoints
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        KML += "Waypoints"
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderOpen", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        
        let waypointTypes = ["Camp", "Picnic", "Parking", "POI", "Junction"]
        
        for type in waypointTypes {
            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
            KML += type
            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
            
            for node in graph.nodes {
                if node.type == type {
                    KML += KMLForNode(node, visible: type == "Junction" ? false : true)
                }
            }
            
            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        }
        
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        //  Trails
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        KML += "Trails"
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        var trailUsed: Dictionary<String, Bool> = Dictionary()
        // Each node...
        for node in graph.nodes {
            for edge in node.edges {
                
                if trailUsed[edge.name] == nil {
                    // new trail! fill out the entire trail
                    
                    if clean {
                        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
                        KML += edge.name
                        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2White", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
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
                                            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
                                            KML += String("\(searchEdge.name),\(searchEdge.segment)")
                                            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2White", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
                                            KML += CoordinatesForEdge(searchEdge, forward: true)
                                            KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
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
                        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
                    }
                    
                    trailUsed[edge.name] = true
                }
                
            }
        }
        
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("FolderFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        //  end of KML
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        KML.writeToFile("/Users/taylorg/Local Reference/Graphs/Graphs/graph.kml", atomically: true, encoding:NSUTF8StringEncoding, error: nil)
    }   
    
    class func writeKML(route: Route, pathOnly: Bool) {
        
        var content: String = KMLForRoute(route, pathOnly: pathOnly)
        content.writeToFile("/Users/taylorg/Local Reference/Graphs/Graphs/output.kml", atomically: true, encoding:NSUTF8StringEncoding, error: nil)
    }
    
    class func KMLForRoute(route: Route, pathOnly: Bool) -> String {
        
        var KML = String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
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
        
        KML += String(contentsOfFile: NSBundle.mainBundle().pathForResource("KMLFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        return KML
    }
    
    class func KMLForNode (node: Node, visible: Bool) -> String {
        var header = String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        if !visible {
            header += String(contentsOfFile: NSBundle.mainBundle().pathForResource("Invisible", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        }
        let section2 = String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection2", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        let name = node.name
        
        let section3 = String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection3", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        let coordinateString = "\(node.coordinate.longitude),\(node.coordinate.latitude),0 "
        
        let section4 = String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeSection4", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
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
        
        let footer = String(contentsOfFile: NSBundle.mainBundle().pathForResource("NodeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
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
        let header = String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeHeader", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        let name = pathName
        let section2 = String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeSection2Blue", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        let coordinateString = pathCoordinates
        let footer = String(contentsOfFile: NSBundle.mainBundle().pathForResource("EdgeFooter", ofType: "txt")!, encoding: NSUTF8StringEncoding, error: nil)!
        
        return String("\(header)\(name)\(section2)\(coordinateString)\(footer)")
    }
    
    
}