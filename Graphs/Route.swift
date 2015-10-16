//
//  Route.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/28/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class Route {
    let startingNode: Node
    let edges: [Edge]
    var nodes: [Node] = []
    let endingNode: Node
    
    init(startingNode: Node, edges:[Edge], endingNode: Node) {
        self.startingNode = startingNode
        self.edges = edges
        self.endingNode = endingNode
        
        
        var mostDistantNode = startingNode
        for edge in self.edges {
            nodes.append(mostDistantNode)
            if edge.head === mostDistantNode {
                mostDistantNode = edge.tail
            }
            else {
                mostDistantNode = edge.head
            }
        }
        nodes.append(mostDistantNode)

    }

    func newRouteByAddingEdge(edge: Edge) -> Route {
        
        var newEdges: [Edge] = self.edges
        newEdges.append(edge)
        var newEndingNode = endingNode
        return Route(startingNode: self.startingNode, edges: newEdges, endingNode: newEndingNode)
    }
    
    func distance() -> Double {
        var totalDistance: Double = 0
        var totalClimb: Int = 0
        var totalDescent: Int = 0
        var currentNode = startingNode
        for edge in self.edges {
            totalDistance += edge.getDistanceFrom(currentNode)
            totalClimb += edge.getClimbFrom(currentNode)
            totalDescent += edge.getDescentFrom(currentNode)
            currentNode = edge.getDestinationNode(currentNode)
        }
        return totalDistance
    }
        
    func listAllSteps() {
        var mostDistantNode = startingNode
        print("Route: ")
        for edge in self.edges {
            print(mostDistantNode.name + ", ")
            //print(edge.name + " until ")
            if edge.head === mostDistantNode {
                mostDistantNode = edge.tail
            }
            else {
                mostDistantNode = edge.head
            }
        }
        print(mostDistantNode.name + " --> distance: ")
        println(distance())
    }
    
    func toEdge() -> Edge {
        //let edge = Edge(name: String, segment: Int, head: Node, tail: Node, distance: Double, climb: Int, descent: Int, coordinates: [Coordinate])
        
        var distance = 0.0
        var climb = 0
        var descent = 0
        var coordinates = [Coordinate]()
        
        var mostDistantNode = startingNode
        for edge in self.edges {
            distance += edge.distance
            if edge.head === mostDistantNode {
                mostDistantNode = edge.tail
                climb += edge.descent
                descent += edge.climb
                for coordinate in edge.coordinates.reverse() {
                    coordinates.append(coordinate)
                }
            }
            else {
                mostDistantNode = edge.head
                climb += edge.climb
                descent += edge.descent
                for coordinate in edge.coordinates {
                    coordinates.append(coordinate)
                }
            }
        }
        return Edge(name: "Your Route", segment: 1, head: self.endingNode, tail: self.startingNode, distance: distance, climb: climb, descent: descent, coordinates: coordinates)
    }
}