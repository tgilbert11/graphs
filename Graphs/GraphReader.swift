//
//  GraphReader.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 12/2/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class GraphReader {
    
    class func readGraph() -> Graph {
        
        var numberOfCoordinates = 0
        
        let path = NSBundle.mainBundle().pathForResource("nodes,edges", ofType: "txt")!
        let text = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        let lines: [String] = text.componentsSeparatedByString("\n")
        
        let coordinateData = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("coordinateData", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let coordinateLines = coordinateData.componentsSeparatedByString("\n")
        
        let graph = Graph(name: "Ventana Wilderness")
        
        var finishedWithNodes: Bool = false
        var finishedWithEdges: Bool = false
        
        var state: Int = 0
        
        while state < 2 {
            var i: Int = 0
            assert(lines.count > 0, "no data")
            for line in lines {
                let titleData: [String] = line.componentsSeparatedByString(":")
                assert(titleData.count == 2, "Colon issue on line \(i): " + line)
                
                if titleData[0] == "Node" {
                    if state == 0 {
                        //println("node")
                        let nodeData: [String] = titleData[1].componentsSeparatedByString(",")
                        assert(nodeData.count == 3, "Node data issue on line \(i): " + line)
                        
                        for part: String in nodeData {
                            assert(part.characters.count > 0, "part too short on line \(i): " + line)
                        }
                        
                        let nodeName: String? = nodeData[0]
                        assert(nodeName != nil, "node name issue on line \(i): " + line)
                        for node in graph.nodes {
                            assert(node.name != nodeName, "duplicate node name on line \(i): " + line)
                        }
                        
                        let elevation: Int? = Int(nodeData[1])
                        assert(elevation != nil, "elevation issue on line \(i): " + line)
                        
                        let type: String? = nodeData[2]
                        assert(type != nil, "node type issue on line \(i): " + line)
                        
                        // Coordinate Creation -- UNSAFE
                        var coordinate: Coordinate?
                        assert(coordinateLines.count > 1, "coordinate splitting issue on line \(i): " + line)
                        var nodeFound: Bool = false
                        for line in coordinateLines {
                            if nodeFound {
                                // HERE
                                let coordinateComponents = line.componentsSeparatedByString(",")
                                let longitude: Double = (coordinateComponents[0] as NSString).doubleValue
                                let latitude: Double = (coordinateComponents[1] as NSString).doubleValue
                                coordinate = Coordinate(longitude: longitude, latitude: latitude)
                                numberOfCoordinates++
                                break
                            }
                            let titleData: [String] = line.componentsSeparatedByString(":")
                            if titleData.count == 2 {
                                if titleData[0] == "Node" && titleData[1] == nodeName! {
                                    nodeFound = true
                                    continue
                                }
                            }
                        }
                        assert(nodeFound, "node not found on line \(i): " + line)
                        assert(coordinate != nil, "coordinate creation issue on line \(i): " + line)
                        
                        graph.addNode(Node(name: nodeName!, elevation: elevation!, type: type!, coordinate: coordinate!))
                    }
                }
                else if titleData[0] == "Edge" {
                    if state == 1 {
                        //println("edge")
                        // Read Data
                        let edgeData: [String] = titleData[1].componentsSeparatedByString(",")
                        assert(edgeData.count == 7, "Edge data issue on line \(i): " + line)
                        
                        // Each part has > 0 characters
                        for part: String in edgeData {
                            assert(part.characters.count > 0, "element too short on line \(i): " + line)
                        }
                        
                        // Segment Number
                        let segment: Int? = Int(edgeData[1])
                        assert(segment != nil, "segment number issue on line \(i): " + line)
                        
                        // Edge Name
                        let edgeName: String? = String("\(edgeData[0])")
                        
                        // No duplicates
                        for node in graph.nodes {
                            for edge in node.edges {
                                assert(edge.name == edgeName! && edge.segment != segment! || edge.name != edgeName! && edge.segment == segment! || edge.name != edgeName! && edge.segment != segment!, "duplicate edge name on line \(i): " + line)
                            }
                        }
                        
                        // Edge Tail
                        var tailNode: Node?
                        for node in graph.nodes {
                            if node.name == edgeData[2] {
                                tailNode = node
                            }
                        }
                        assert(tailNode != nil, "missing tail node on line \(i): " + line)
                        
                        // Edge Head
                        var headNode: Node?
                        for node in graph.nodes {
                            if node.name == edgeData[3] {
                                headNode = node
                            }
                        }
                        assert(headNode != nil, "missing head node on line \(i): " + line)
                        
                        // Edge Distance
                        var distance: Double?
                        let distanceParts: [String] = edgeData[4].componentsSeparatedByString(".")
                        if distanceParts.count == 1 {
                            let distanceInt: Int? = Int(distanceParts[0])
                            assert(distanceInt != nil, "distance issue on line \(i): " + line)
                            distance = Double(distanceInt!)
                        }
                        else if distanceParts.count == 2 {
                            let distanceOnesInt: Int? = Int(distanceParts[0])
                            assert(distanceOnesInt != nil, "distance issue on line \(i): " + line)
                            let distanceDecimalInt: Int? = Int(distanceParts[1])
                            assert(distanceDecimalInt != nil, "distance issue on line \(i): " + line)
                            
                            let distanceOnes: Double = Double(distanceOnesInt!)
                            let distanceDecimal: Double = Double(distanceDecimalInt!)
                            assert(distanceParts[1].characters.count == 1, "distance issue on line \(i): " + line)
                            distance = distanceOnes + distanceDecimal / 10
                        }
                        else {
                            assert(false, "distance issue on line \(i): " + line)
                        }
                        
                        // Edge Climb
                        let climb: Int? = Int(edgeData[5])
                        assert(climb != nil, "climb issue on line \(i): " + line)
                        
                        // Edge Descent
                        let descent: Int? = Int(edgeData[6])
                        assert(descent != nil, "descent issue on line \(i): " + line)
                        
                        // Coordinate Creation -- UNSAFE
                        var coordinates: [Coordinate] = []
                        var edgeFound: Bool = false
                        for line in coordinateLines {
                            if edgeFound {
                                // HERE
                                
                                let individualCoordinates = line.componentsSeparatedByString(" ")
                                for coordinateString in individualCoordinates {
                                    let coordinateComponents = coordinateString.componentsSeparatedByString(",")
                                    let longitude: Double = (coordinateComponents[0] as NSString).doubleValue
                                    let latitude: Double = (coordinateComponents[1] as NSString).doubleValue
                                    coordinates.append(Coordinate(longitude: longitude, latitude: latitude))
                                    numberOfCoordinates++
                                }
                                
                                break
                            }
                            let titleData: [String] = line.componentsSeparatedByString(":")
                            if titleData.count == 2 {
                                if titleData[0] == "Edge" && titleData[1] == "\(edgeName!),\(segment!)" {
                                    edgeFound = true
                                    continue
                                }
                            }
                        }
                        
                        // Create Edge
                        let edge: Edge = Edge(name: edgeName!, segment: segment!, head: headNode!, tail: tailNode!, distance: distance!, climb: climb!, descent: descent!, coordinates:coordinates)
                        headNode!.addEdge(edge)
                        tailNode!.addEdge(edge)
                        graph.addEdge(edge)
                    }
                }
                else {
                    assert(false, "Node/Edge error on line \(i): " + line)
                }
                i++
            }
            state++
        }
        print("number of coordinates: \(numberOfCoordinates)")
        return graph
    }
    
    class func switchCoordinateOrder() {
        let path = NSBundle.mainBundle().pathForResource("input", ofType: "txt")!
        let text = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
        let lines: [String] = text.componentsSeparatedByString(" ")
        var output: String = ""
        for var i=0 ; i<lines.count ; i++ {
            output += lines[lines.count-1-i]
            output += i==(lines.count-1) ? "" : " "
        }
        print("switched order")
        do {
            try output.writeToFile("/Users/taylorg/Local Reference/Graphs/Graphs/output.txt", atomically: true, encoding:NSUTF8StringEncoding)
        } catch _ {
        }
    }
    
}