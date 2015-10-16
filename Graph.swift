//
//  Graph.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/28/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class Graph {
    let name: String
    var nodes: [Node] = []
    var edges: [Edge] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addNode(node: Node) {
        self.nodes.append(node)
    }
    
    func addEdge(edge: Edge) {
        self.edges.append(edge)
    }
    
    func nodeCalled(nodeName: String) -> Node? {
        var node: Node?
        for checkNode in nodes {
            if checkNode.name == nodeName {
                node = checkNode
            }
        }
        return node
    }
}