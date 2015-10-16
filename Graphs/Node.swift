//
//  Node.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/28/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation


class Node: Equatable {
    let name: String
    let elevation: Int
    let type: String
    var edges: [Edge] = []
    let coordinate: Coordinate
    
    init(name: String, elevation: Int, type: String, coordinate: Coordinate) {
        self.name = name
        self.elevation = elevation
        self.type = type
        self.coordinate = coordinate
    }
    
    func addEdge(edge: Edge) {
        self.edges.append(edge)
    }
    
}

func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.name==rhs.name
}
