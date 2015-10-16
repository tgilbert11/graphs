//
//  NodeAnnotation.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 12/29/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import MapKit

class NodeAnnotation: MKPointAnnotation {
    
    let node: Node
    
    init(node: Node) {
        self.node = node
    }
    
}