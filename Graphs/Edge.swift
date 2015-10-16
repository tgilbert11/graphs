//
//  Edge.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/28/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class Edge {
    let name: String
    let segment: Int
    let head: Node
    let tail: Node
    let distance: Double
    let climb: Int
    let descent: Int
    let coordinates: [Coordinate]
    
    init(name: String, segment: Int, head: Node, tail: Node, distance: Double, climb: Int, descent: Int, coordinates:[Coordinate]) {
        self.name = name
        self.segment = segment
        self.head = head
        self.tail = tail
        self.distance = distance
        self.climb = climb
        self.descent = descent
        self.coordinates = coordinates
    }
    
    func getDistanceFrom(originNode: Node) -> Double {
        if originNode === head {
            return self.distance
        }
        else {
            return self.distance
        }
    }
    
    func getClimbFrom(originNode: Node) -> Int {
        if originNode === head {
            return self.descent
        }
        else {
            return self.climb
        }
    }
    
    func getDescentFrom(originNode: Node) -> Int {
        if originNode === head {
            return self.climb
        }
        else {
            return self.descent
        }
    }
    
    func getDestinationNode(startingNode: Node) -> Node {
        if startingNode === self.head {
            return self.tail
        }
        else {
            return self.head
        }
    }
}