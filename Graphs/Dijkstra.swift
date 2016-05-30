//
//  Dijkstra.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/29/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class Dijkstra {

    class func findShortestRoute(graph: Graph, startNode: Node, endNode: Node) -> Route {
        
        var visitedNodes: [Node] = []
        var searchScratchpad: Dictionary<String, (distance: Double, route: Route)> = Dictionary()

        for node in graph.nodes {
            searchScratchpad[node.name] = (Double.infinity, Route(startingNode: startNode, edges: [], endingNode: startNode))
        }
        
        var currentNode: Node = startNode
        var currentRoute: Route = Route(startingNode: startNode, edges: [], endingNode: startNode)
        var currentDistance: Double = 0
        searchScratchpad[startNode.name] = (currentDistance, currentRoute)
        
        while true {
            
            currentRoute = searchScratchpad[currentNode.name]!.route
            currentDistance = currentRoute.distance()
            
            for edge in currentNode.edges {
                let destinationNode: Node = edge.getDestinationNode(currentNode)
                if visitedNodes.contains(destinationNode) {
//                if contains(visitedNodes, destinationNode) {
                    continue
                }
                let newDistance: Double = currentDistance + edge.getDistanceFrom(currentNode)
                let previousDistance: Double = searchScratchpad[destinationNode.name]!.distance
                if newDistance < previousDistance {
                    searchScratchpad[destinationNode.name] = (newDistance, currentRoute.newRouteByAddingEdge(edge))
                }
            }
            
            if currentNode === endNode {
                break
            }
            
            // stop when destination found
            visitedNodes.append(currentNode)
            let newNode: Node? = findShortestUnvisited(graph, searchScratchpad: searchScratchpad, visitedNodes: visitedNodes)
            if newNode != nil {
                currentNode = newNode!
            }
            
            // stop when all nodes mapped
            if visitedNodes.count == graph.nodes.count {
                //break
            }
        }
        return currentRoute
    }
    
    class func findShortestUnvisited(graph: Graph, searchScratchpad: Dictionary<String, (distance: Double, route: Route)>, visitedNodes: [Node]) -> Node? {
        var shortestNode: Node?
        var shortestDistance: Double = Double.infinity
        for node in graph.nodes {
            if searchScratchpad[node.name]!.distance <= shortestDistance && !visitedNodes.contains(node){
//                if searchScratchpad[node.name]!.distance <= shortestDistance && !contains(visitedNodes, node){
                shortestNode = node
                shortestDistance = searchScratchpad[node.name]!.distance
            }
        }
        return shortestNode
    }
    
}