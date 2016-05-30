//
//  ViewController.swift
//  Graphs
//
//  Created by Taylor H. Gilbert on 11/26/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import UIKit
import SceneKit
import GLKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    let printMethodCalls = false
    var lastPrintedMethodName = ""
    var isLooping = false
    
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startingPointButton: UIBarButtonItem!
    @IBOutlet weak var endingPointButton: UIBarButtonItem!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var climbLabel: UILabel!
    @IBOutlet weak var descentLabel: UILabel!
    
    var isWaitingForStartingPointInput = false
    var isWaitingForEndingPointInput = false
    
    var currentRoute: Route?
    var startingNode: Node?
    var currentNode: Node?
    var lastSelectedAnnotationView: MKAnnotationView?
    //var currentRoute: Route?
    var endingNode: Node?
    var passthroughs = [Node]()
    var isReAddingAnnotation = false
    
    var waypoints = [Node]()
    var routeSegments = [Route]()
    var routeCompleted = false
    
    var graph: Graph? = nil
    
    override func viewDidLoad() {
        startedMethodNamed("viewDidLoad")
        super.viewDidLoad()
        
        self.graph = GraphReader.readGraph()
        //KMLWriter.KMLForEntireGraph(self.graph!, clean: false)
        
        //        let sophomoreExpedition = ["Kirk Creek","Vicente Flat","Fresno","Cook Spring","Lost Valley","Indian Valley","Strawberry", "Bear Basin", "Hiding Canyon","Upper Pat Spring", "Bottchers Gap"]
        //        let trip = ["Los Padres Dam","Upper Pat Spring","Hiding Canyon","Los Padres Dam"]
        //        let trip2 = ["Junction 9","Black Cone Camp"]
        //        let test = ["Junction 8","Junction 46"]
        //
        //        let waypoints = trip2
        //        assert(waypoints.count>1, "too few waypoints, search doesn't make sense. ")
        //
        //        var route: Route? = nil
        //        var routes = [Route]()
        //
        //        for var i=0 ; i<waypoints.count-1 ; i++ {
        //            var startNode: Node? = self.graph!.nodeCalled(waypoints[i])
        //            assert(startNode != nil, "Specified Node can't be found.")
        //            var endNode: Node? = self.graph!.nodeCalled(waypoints[i+1])
        //            assert(endNode != nil, "Specified Node can't be found.")
        //
        //            let newRoute = Dijkstra.findShortestRoute(self.graph!, startNode: startNode!, endNode: endNode!)
        //            routes.append(newRoute)
        //
        //            if route == nil {
        //                route = newRoute
        //            }
        //            else {
        //                for edge in newRoute.edges {
        //                    route = route!.newRouteByAddingEdge(edge)
        //                }
        //            }
        //
        //            newRoute.listAllSteps()
        //        }
        //
        //        println("\n\n")
        //
        //        println("Full Route:")
        //        assert(route != nil, "route not route never initialized")
        //        route!.listAllSteps()
        //KMLWriter.writeKML(route!, pathOnly: true)
        
        //GraphReader.switchCoordinateOrder()
        
        //sceneSetup()
        //sceneView.scene!.rootNode.addChildNode(ViewController.TNTMolecule())
        
        self.mapView.region = self.mapView.regionThatFits(MKCoordinateRegionMake(CLLocationCoordinate2DMake(36.20467125771643, -121.6022022788383), MKCoordinateSpanMake(0.3, 0.3)))
        self.mapView.mapType = MKMapType.Hybrid
        self.mapView.pitchEnabled = true
        self.mapView.camera.pitch = 50
        
        //var mapItems = [MKMapItem]()
        for node in self.graph!.nodes {
            //var mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(node.coordinate.latitude, node.coordinate.longitude), addressDictionary: Dictionary()))
            //mapItem.name = node.name
            //mapItems.append(mapItem)
            if node.type != "Junction" || false { // to enable junctions, change false to true
                var annotation = NodeAnnotation(node: node)
                annotation.coordinate = CLLocationCoordinate2DMake(node.coordinate.latitude, node.coordinate.longitude)
                annotation.title = annotation.node.name
                annotation.subtitle = String("Elevation: \(annotation.node.elevation) ft")
                self.mapView.addAnnotation(annotation)
            }
        }
        for edge in self.graph!.edges {
            var coordinates = [CLLocationCoordinate2D]()
            //println("\(edge.name),\(edge.segment)")
            for coordinate in edge.coordinates {
                coordinates.append(CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
                //println(ElevationGetter.getElevation(coordinate.latitude, longitude: coordinate.longitude)!)
                //mapItems.append(MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude), addressDictionary: Dictionary())))
            }
            var polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            polyline.title = String("\(edge.name),\(edge.segment)")
            //mapItems.append(polyline)
            self.mapView.addOverlay(polyline)
        }
        
        for polyline in RiverReader.readRiver() {
            self.mapView.addOverlay(polyline)
        }
        
        //MKMapItem.openMapsWithItems(mapItems, launchOptions: nil)
        
        //        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didSelectNodeFromMap:"))
        //        tapGestureRecognizer.delegate = self
        //        self.mapView.addGestureRecognizer(tapGestureRecognizer)
        
        self.routeLabel.text = "Route: --"
        self.distanceLabel.text = "Distance: --.-"
        self.climbLabel.text = "Climb: --"
        self.descentLabel.text = "Descent: --"
        
        //println("test elevation: \(ElevationGetter.getElevation(36, longitude: -120)!)")
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        startedMethodNamed("gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:")
        return true
    }
    
    
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        startedMethodNamed("mapView:didSelectAnnotationView:")
        self.lastSelectedAnnotationView = view
        //println("new lastSelectedAnnotationView: \((self.lastSelectedAnnotationView!.annotation as NodeAnnotation).node.name)")
        if view.annotation!.isKindOfClass(NodeAnnotation) {
            
            let nodeAnnotation = view.annotation as! NodeAnnotation
            let node: Node = nodeAnnotation.node
            clearRoutes(false, andAlsoClearTest: true)
            //println("exited clearRoutes 4")
            //println("selected: \(node.name)")
            //self.currentNode = node
            
            if !isReAddingAnnotation {
                isReAddingAnnotation = true
                let annotation = view.annotation
                self.mapView.removeAnnotation(annotation!)
                self.mapView.addAnnotation(annotation!)
                self.mapView.selectAnnotation(annotation!, animated: true)
                isReAddingAnnotation = false
            }
            else if self.waypoints.count > 0 && !routeCompleted {
                
                //println("  --- started Dijkstra ---")
                // THIS IS A LONG OPERATION
                currentRoute = Dijkstra.findShortestRoute(self.graph!, startNode: self.waypoints.last!, endNode: node)
                //println("  ---  ended  Dijkstra ---")
                let title = String("testRoute: \(currentRoute!.startingNode.name) to \(currentRoute!.endingNode.name)")
                //println("did select \(title)")
                addOverlayForRoute(currentRoute!, title: title)
                
            }
            //println(" - mark 2")
            var nodeInWaypoints = false
            for testNode in self.waypoints {
                if node == testNode {
                    //println("node == testNode")
                    nodeInWaypoints = true
                }
                else {
                    //println("node != testNode")
                }
            }
            //println(" - mark 3")
            view.image = annotationViewImageForNode(node, highlighted: nodeInWaypoints)
            //println("exited mapView:didSelectAnnotationView:")
        }
    }
    
    func addOverlayForRoute(route: Route, title: String) {
        startedMethodNamed("addOverlayForRoute:")
        let routeEdge = route.toEdge()
        var coordinates = [CLLocationCoordinate2D]()
        for coordinate in routeEdge.coordinates {
            coordinates.append(CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude))
        }
        
        var polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        self.routeLabel.text = "Route: \(route.startingNode.name) to \(route.endingNode.name)"
        self.distanceLabel.text = "Distance: \(route.distance()) mi"
        self.climbLabel.text = "Climb: \(routeEdge.climb) ft"
        self.descentLabel.text = "Descent: \(routeEdge.descent) ft"
        polyline.title = title
        //println("adding an overlay")
        self.mapView.addOverlay(polyline)
        //println("overlay added")
    }
    
    func clearRoutes(confirmed: Bool, andAlsoClearTest test: Bool) {
        startedMethodNamed("clearRoutes:andAlsoClearTest:")
        if true { //self.mapView.overlays != nil {
            //println("overlays not nil")
            if confirmed {
                self.waypoints.removeAll(keepCapacity: false)
                self.passthroughs.removeAll(keepCapacity: false)
                for object in self.mapView.annotations {
                    if object.isKindOfClass(NodeAnnotation) {
                        //println("object is NodeAnnotation")
                        let annotationView = self.mapView.viewForAnnotation(object as MKAnnotation)
                        annotationView!.image = annotationViewImageForNode((object as! NodeAnnotation).node, highlighted: false)
                    }
                }
            }
            for overlay in self.mapView.overlays {
                //println("overlay loop iteration")
                if overlay.isKindOfClass(MKPolyline) {
                    //println("overlay is MKOverlay")
                    let mkPolyline = overlay as! MKPolyline
                    var doesOverlayExistInRoutes = false
                    //println("started doesExist comparison")
                    for route in self.routeSegments {
                        let title = String("route: \(route.startingNode.name) to \(route.endingNode.name)")
                        //println("clear routes \(title)")
                        if mkPolyline.title == title {
                            //println("overlay exists")
                            doesOverlayExistInRoutes = true
                        }
                    }
                    //println("ended   doesExist comparison")
                    //println("started remove comparison")
                    let firstFiveOfPolylineTitle = mkPolyline.title!.substringToIndex(mkPolyline.title!.startIndex.advancedBy(5))
                    if confirmed && firstFiveOfPolylineTitle == "route" ||  test && firstFiveOfPolylineTitle == "testR" || !confirmed && firstFiveOfPolylineTitle == "route" && !doesOverlayExistInRoutes {
                        //println(mkPolyline.title!)
                        //println("removing an overlay")
                        self.mapView.removeOverlay(mkPolyline)
                        //println("overlay removed")
                    }
                    //println("ended   remove comparison")
                }
                else {
                    //println("overlay is not MKOverlay")
                }
            }
        }
    }
    
    @IBAction func pinchingDidOccur() {
        startedMethodNamed("pinchingDidOccur")
        //println("latitude delta: \(self.mapView.region.span.latitudeDelta), longitude delta: \(self.mapView.region.span.longitudeDelta)")
        //println("here")
        if true { // self.mapView.annotations != nil {
            //println("there")
            for annotation in self.mapView.annotations {
                //println("everywhere")
                if annotation.isKindOfClass(MKPointAnnotation) {
                    //println("a fourth place")
                    //println("self.mapView: \(self.mapView != nil)")
                    let annotationView: MKAnnotationView? = self.mapView.viewForAnnotation(annotation as! MKPointAnnotation)
                    if annotationView != nil {
                        let scale = scaleRightNow()
                        self.mapView.viewForAnnotation((annotation as! MKPointAnnotation))!.transform = CGAffineTransformMakeScale(scale, scale)
                    }
                    else {
                        //println("huh.")
                    }
                }
            }
        }
    }
    
    func scaleRightNow() -> CGFloat {
        startedMethodNamed("scaleRightNow")
        var scale = CGFloat(1.0)
        if self.mapView.region.span.latitudeDelta > 0.45 {
            scale = CGFloat(0.45/self.mapView.region.span.latitudeDelta)
        }
        else if self.mapView.region.span.latitudeDelta < 0.0075 {
            scale = CGFloat(0.0075/self.mapView.region.span.latitudeDelta)
        }
        return scale
    }
    
//    @IBAction func didTapStartingPointButton() {
//        println("start")
//    }
//    
//    @IBAction func didTapEndingPointButton() {
//        println("end")
//    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        startedMethodNamed("mapView:rendererForOverlay:")
        if overlay.isKindOfClass(MKPolyline) {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            let overlayFirstFive = overlay.title!!.substringToIndex(overlay.title!!.startIndex.advancedBy(5))
            if overlayFirstFive == "testR" {
                polylineRenderer.strokeColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
                polylineRenderer.lineWidth = 4
            }
            else if overlayFirstFive == "route" {
                polylineRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
                polylineRenderer.lineWidth = 4
            }
            else if overlayFirstFive == "river" {
                polylineRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
                let riverBits = overlay.title!!.componentsSeparatedByString(":")
                let riverSize = Int(riverBits[1])!
                polylineRenderer.lineWidth = CGFloat(Double(riverSize)/17+1)
            }
            else {
                polylineRenderer.strokeColor = UIColor.whiteColor()
                polylineRenderer.lineWidth = 1
            }
            return polylineRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        startedMethodNamed("mapView:viewForAnnotation:")
        //println("view for annotation")
        if annotation.isKindOfClass(NodeAnnotation) {
            let annotationReuseIdentifier = String("\((annotation as! NodeAnnotation).node.name)")
            var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseIdentifier)
            //var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "node")
            annotationView.canShowCallout = true
            let node = (annotation as! NodeAnnotation).node
            var nodeInWaypoints = false
            for testNode in self.waypoints {
                if node == testNode {
                    nodeInWaypoints = true
                }
            }
            annotationView.image = annotationViewImageForNode((annotation as! NodeAnnotation).node, highlighted: nodeInWaypoints)
            let scale = scaleRightNow()
            annotationView.transform = CGAffineTransformMakeScale(scale, scale)
            
            
            if self.waypoints.count == 0 || routeCompleted {
                var button = UIButton(type: UIButtonType.ContactAdd) as UIButton
                button.setImage(UIImage(named: "arrow.png"), forState: UIControlState.Normal)
                button.setTitle("\(node.name);1", forState: UIControlState.Normal)
                annotationView.rightCalloutAccessoryView = button
            }
            else if annotationView.reuseIdentifier != self.waypoints[self.waypoints.count-1].name {
                //println("annotationView: \(annotationView.reuseIdentifier)")
                //println("lastSelectedAnnotationView: \(self.lastSelectedAnnotationView!.reuseIdentifier)")
                var buttonView = UIView(frame: CGRectMake(0, 0, 93, 22))
                
                var button1View = UIView(frame: CGRectMake(5, 0, 22, 22))
                var button1 = UIButton(type: UIButtonType.ContactAdd) as UIButton
                button1.setImage(UIImage(named: "walking.png"), forState: UIControlState.Normal)
                button1.setTitle("\(node.name);1", forState: UIControlState.Normal)
                button1.addTarget(self, action: "didTapActionButton:", forControlEvents: UIControlEvents.TouchUpInside)
                button1View.addSubview(button1)
                
                var button2View = UIView(frame: CGRectMake(38, 0, 22, 22))
                var button2 = UIButton(type: UIButtonType.ContactAdd) as UIButton
                button2.setImage(UIImage(named: "night.png"), forState: UIControlState.Normal)
                button2.setTitle("\(node.name);2", forState: UIControlState.Normal)
                button2.addTarget(self, action: "didTapActionButton:", forControlEvents: UIControlEvents.TouchUpInside)
                button2View.addSubview(button2)
                
                var button3View = UIView(frame: CGRectMake(71, 0, 22, 22))
                var button3 = UIButton(type: UIButtonType.ContactAdd) as UIButton
                button3.setImage(UIImage(named: "parkingThin.png"), forState: UIControlState.Normal)
                button3.setTitle("\(node.name);3", forState: UIControlState.Normal)
                button3.addTarget(self, action: "didTapActionButton:", forControlEvents: UIControlEvents.TouchUpInside)
                button3View.addSubview(button3)
                
                buttonView.addSubview(button1View)
                buttonView.addSubview(button2View)
                buttonView.addSubview(button3View)
                annotationView.rightCalloutAccessoryView = buttonView
            }
            else {
                //println("annotation views equal")
                var button = UIButton(type: UIButtonType.ContactAdd) as UIButton
                button.setImage(UIImage(named: "delete.png"), forState: UIControlState.Normal)
                button.setTitle("\(node.name);2", forState: UIControlState.Normal)
                annotationView.rightCalloutAccessoryView = button
            }
            
            return annotationView
        }
        //println("nil from mapView.viewForAnnotation")
        return nil
    }
    
    func didTapActionButton(sender: AnyObject) {
        startedMethodNamed("didTapActionButton:")
        // print("tapped: ")
        if sender.isKindOfClass(UIButton) {
            let button = sender as! UIButton
            //println(button.titleForState(UIControlState.Normal)!)
            let titleComponents = button.titleForState(UIControlState.Normal)!.componentsSeparatedByString(";")
            let node = self.graph!.nodeCalled(titleComponents[0])!
            let buttonNumber = Int(titleComponents[1])!
            //println("\(node.name), button: \(buttonNumber)")
            switch (buttonNumber) {
            case 1:
                print("walking")
                addPassthrough(node)
            case 2:
                //println("sleeping")
                addStop(node)
            case 3:
                //println("parking")
                addStop(node)
                self.routeCompleted = true
                refreshCalloutViewForNode(node)
            default:
                1 == 1
            }
        }
    }
    
    func refreshCalloutViewForNode(node: Node) {
        startedMethodNamed("refreshCalloutViewForNode:")
        var annotation: MKAnnotation? = nil
        for testAnnotation in self.mapView.annotations {
            if (testAnnotation as! NodeAnnotation).node == node {
                // println("matched")
                annotation = (testAnnotation as MKAnnotation)
            }
        }
        self.mapView.deselectAnnotation(annotation!, animated: true)
        self.mapView.selectAnnotation(annotation!, animated: true)
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        startedMethodNamed("mapView:annotationView:calloutAccessoryControlTapped:")
        let node = (view.annotation as! NodeAnnotation).node
        //println("\((view.annotation as NodeAnnotation).node.name)")
        let titleComponents = (control as! UIButton).titleForState(UIControlState.Normal)!.componentsSeparatedByString(";")
        let buttonNumber = Int(titleComponents[1])!
        
        if buttonNumber == 1 {
            self.addStop(node)
        }
        else {
            self.removeStop(node)
        }
    }
    
    func annotationViewImageForNode(node: Node, highlighted: Bool) -> UIImage {
        startedMethodNamed("annotationViewImageForNode:highlighted:")
        var image: UIImage?
        switch (node.type) {
        case "Camp":
            if highlighted { image = UIImage(named: "campRed.png") }
            else { image = UIImage(named: "Camp.png") }
        case "Picnic":
            if highlighted { image = UIImage(named: "picnicRed.png") }
            else { image = UIImage(named: "Picnic.png") }
        case "Parking":
            if highlighted { image = UIImage(named: "parkingRed.png") }
            else { image = UIImage(named: "Parking.png") }
        case "Junction":
            if highlighted { image = UIImage(named: "junctionRed.png") }
            else { image = UIImage(named: "Junction.png") }
        case "POI":
            if highlighted { image = UIImage(named: "POIRed.png") }
            else { image = UIImage(named: "POI.png") }
        default:
            if highlighted { image = UIImage(named: "POIRed.png") }
            else { image = UIImage(named: "POI.png") }
        }
        return UIImage(CGImage: image!.CGImage!, scale: 6, orientation: image!.imageOrientation)
    }
    
    func addPassthrough(node: Node) {
        startedMethodNamed("addPassthrough:")
        self.passthroughs.append(node)
    }
    
    func addStop(node: Node) {
        startedMethodNamed("addStop:")
        //println("do they match: \(node.name == (self.lastSelectedAnnotationView!.annotation as NodeAnnotation).node.name)")
        self.lastSelectedAnnotationView!.image = annotationViewImageForNode(node, highlighted: true)

        if self.routeCompleted {
            self.waypoints.removeAll(keepCapacity: false)
            //println("clear routes here")
            clearRoutes(true, andAlsoClearTest: true)
            //println("exited clearRoutes 1")
            self.routeCompleted = false
        }
        
        self.waypoints.append(node)
        if waypoints.count == 1 {
            // println("first waypoint")
        }
        else if waypoints.count > 1 {
            let secondToLastNode = waypoints[waypoints.count - 2]
            if passthroughs.count == 0 {
                self.routeSegments.append(currentRoute!)
                //currentRoute!.listAllSteps()
                clearRoutes(false, andAlsoClearTest: true)
                //println("exited clearRoutes 2")
                addOverlayForRoute(currentRoute!, title: String("route: \(currentRoute!.startingNode.name) to \(currentRoute!.endingNode.name)")
                )
            }
//            else {
//                let passStartNode = way
//            }
            
            
        }
        refreshCalloutViewForNode(node)
        //self.routeSegments.append(route)
    }
    
    func removeStop(node: Node) {
        startedMethodNamed("removeStop:")
        //println("removeStop")
        self.waypoints.removeLast()
        if self.routeSegments.count > 0 {
            self.routeSegments.removeLast()
        }
        clearRoutes(false, andAlsoClearTest: false)
        //println("exited clearRoutes 3")
        refreshCalloutViewForNode(node)
    }
    
    func startedMethodNamed(name: String) {
        if self.printMethodCalls {
            if self.lastPrintedMethodName == name {
                if self.isLooping {
                    print(".")
                }
                else {
                    print(" looped .")
                    self.isLooping = true
                }
            }
            else {
                self.isLooping = false
                print("\n\(name)")
                self.lastPrintedMethodName = name
            }
        }
    }
    
    
    func sceneSetupBox() {
        
        let scene = SCNScene()
        sceneView.scene = scene
        //sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        let boxGeometry = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 1)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3(x: 20, y: 50, z: 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 25)
        scene.rootNode.addChildNode(cameraNode)
    }
    func sceneSetup() {
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLightTypeOmni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3(x: 20, y: 50, z: 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 25)
        scene.rootNode.addChildNode(cameraNode)
    }
    class func allAtoms() -> SCNNode {
        let atomsNode = SCNNode()
        
        let carbonNode = SCNNode(geometry: carbonAtom())
        carbonNode.position = SCNVector3Make(-6, 0, 0)
        atomsNode.addChildNode(carbonNode)
        
        let hydrogenNode = SCNNode(geometry: hydrogenAtom())
        hydrogenNode.position = SCNVector3Make(-2, 0, 0)
        atomsNode.addChildNode(hydrogenNode)
        
        let oxygenNode = SCNNode(geometry: oxygenAtom())
        oxygenNode.position = SCNVector3Make(+2, 0, 0)
        atomsNode.addChildNode(oxygenNode)
        
        let fluorineNode = SCNNode(geometry: fluorineAtom())
        fluorineNode.position = SCNVector3Make(+6, 0, 0)
        atomsNode.addChildNode(fluorineNode)
        
        return atomsNode
    }
    class func carbonAtom() -> SCNGeometry {
        let carbonAtom = SCNSphere(radius: 1.7)
        carbonAtom.firstMaterial!.diffuse.contents = UIColor.darkGrayColor()
        carbonAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return carbonAtom
    }
    class func hydrogenAtom() -> SCNGeometry {
        let hydrogenAtom = SCNSphere(radius: 1.20)
        hydrogenAtom.firstMaterial!.diffuse.contents = UIColor.lightGrayColor()
        hydrogenAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return hydrogenAtom
    }
    class func oxygenAtom() -> SCNGeometry {
        let oxygenAtom = SCNSphere(radius: 1.52)
        oxygenAtom.firstMaterial!.diffuse.contents = UIColor.redColor()
        oxygenAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return oxygenAtom
    }
    class func fluorineAtom() -> SCNGeometry {
        let fluorineAtom = SCNSphere(radius: 1.47)
        fluorineAtom.firstMaterial!.diffuse.contents = UIColor.yellowColor()
        fluorineAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return fluorineAtom
    }
    class func nitrogenAtom() -> SCNGeometry {
        let nitrogenAtom = SCNSphere(radius: 1.55)
        nitrogenAtom.firstMaterial!.diffuse.contents = UIColor.blueColor()
        nitrogenAtom.firstMaterial!.specular.contents = UIColor.whiteColor()
        return nitrogenAtom
    }
    class func methaneMolecule() -> SCNNode {
        var methaneMolecule = SCNNode()
        
        let carbonNode1 = nodeWithAtom(carbonAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, 0, 0))
        let hydrogenNode1 = nodeWithAtom(hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(-4, 0, 0))
        let hydrogenCylinder1 = cylinderBetweenNodes(carbonNode1, endNode: hydrogenNode1, molecule: methaneMolecule)
        let hydrogenNode2 = nodeWithAtom(hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(+4, 1, 3))
        let hydrogenCylinder2 = cylinderBetweenNodes(carbonNode1, endNode: hydrogenNode2, molecule: methaneMolecule)
        let hydrogenNode3 = nodeWithAtom(hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, -4, 0))
        let hydrogenCylinder3 = cylinderBetweenNodes(carbonNode1, endNode: hydrogenNode3, molecule: methaneMolecule)
        let hydrogenNode4 = nodeWithAtom(hydrogenAtom(), molecule: methaneMolecule, position: SCNVector3Make(0, +4, 0))
        let hydrogenCylinder4 = cylinderBetweenNodes(carbonNode1, endNode: hydrogenNode4, molecule: methaneMolecule)
        
        return methaneMolecule
    }
    class func ethanolMolecule() -> SCNNode {
        var ethanolMolecule = SCNNode()
        let car1 = nodeWithAtom(carbonAtom(), molecule: ethanolMolecule, position: SCNVector3Make(0, 0, 0))
        let car2 = nodeWithAtom(carbonAtom(), molecule: ethanolMolecule, position: SCNVector3Make(4, 0, 0))
        let cyl1 = cylinderBetweenNodes(car1, endNode: car2, molecule: ethanolMolecule)
        let hyd1 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(-2, 0, -2.83))
        let cyl2 = cylinderBetweenNodes(car1, endNode: hyd1, molecule: ethanolMolecule)
        let hyd2 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(-2, 2.83, 2))
        let cyl3 = cylinderBetweenNodes(car1, endNode: hyd2, molecule: ethanolMolecule)
        let hyd3 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(-2, -2.83, 2))
        let cyl4 = cylinderBetweenNodes(car1, endNode: hyd3, molecule: ethanolMolecule)
        let hyd4 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(6, 2.83, -2))
        let cyl5 = cylinderBetweenNodes(car2, endNode: hyd4, molecule: ethanolMolecule)
        let hyd5 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(6, -2.83, -2))
        let cyl6 = cylinderBetweenNodes(car2, endNode: hyd5, molecule: ethanolMolecule)
        let oxy1 = nodeWithAtom(oxygenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(6, 0, 2.83))
        let cyl7 = cylinderBetweenNodes(car2, endNode: oxy1, molecule: ethanolMolecule)
        let hyd6 = nodeWithAtom(hydrogenAtom(), molecule: ethanolMolecule, position: SCNVector3Make(10, 0, 2.83))
        let cyl8 = cylinderBetweenNodes(oxy1, endNode: hyd6, molecule: ethanolMolecule)
        return ethanolMolecule
    }
    class func TNTMolecule() -> SCNNode {
        var TNTMolecule = SCNNode()
        let atom1 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(5.57, -2.46, -3.14))
        let atom2 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(0, -1.84, -3.86))
        let atom3 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(-3.08, 0.42, 0.28))
        let atom4 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(-0.60, 2.02, 5.04))
        let atom5 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(4.89, 1.44, 5.84))
        let atom6 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(7.88, -0.80, 1.70))
        let atom7 = nodeWithAtom(hydrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-5.88, -6.64, -8.05))
        let atom8 = nodeWithAtom(carbonAtom(), molecule: TNTMolecule, position: SCNVector3Make(-2.83, -3.52, -8.94))
        let atom9 = nodeWithAtom(hydrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-4.77, 0, -10.86))
        let atom10 = nodeWithAtom(hydrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-2.94, 3.76, 8.24))
        let atom11 = nodeWithAtom(hydrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-0.29, -5.28, -12.1))
        let atom12 = nodeWithAtom(hydrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(12.14, -1.25, 2.32))
        let atom13 = nodeWithAtom(nitrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-8.86, 1.27, 0))
        let atom14 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-11.3, 3.24, 3.70))
        let atom15 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(-11.62, 0.11, -3.81))
        let atom16 = nodeWithAtom(nitrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(7.41, 3.12, 10.8))
        let atom17 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(12.18, 2.63, 11.51))
        let atom18 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(4.83, 5.08, 14.42))
        let atom19 = nodeWithAtom(nitrogenAtom(), molecule: TNTMolecule, position: SCNVector3Make(9.3, -4.73, -7.02))
        let atom20 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(8.11, -6.38, -11.4))
        let atom21 = nodeWithAtom(oxygenAtom(), molecule: TNTMolecule, position: SCNVector3Make(14.04, -5.1, -6.04))
        let conn1 = cylinderBetweenNodes(atom1, endNode: atom2, molecule: TNTMolecule)
        let conn2 = cylinderBetweenNodes(atom2, endNode: atom3, molecule: TNTMolecule)
        let conn3 = cylinderBetweenNodes(atom3, endNode: atom4, molecule: TNTMolecule)
        let conn4 = cylinderBetweenNodes(atom4, endNode: atom5, molecule: TNTMolecule)
        let conn5 = cylinderBetweenNodes(atom5, endNode: atom6, molecule: TNTMolecule)
        let conn6 = cylinderBetweenNodes(atom6, endNode: atom1, molecule: TNTMolecule)
        let conn7 = cylinderBetweenNodes(atom3, endNode: atom13, molecule: TNTMolecule)
        let conn8 = cylinderBetweenNodes(atom2, endNode: atom8, molecule: TNTMolecule)
        let conn9 = cylinderBetweenNodes(atom16, endNode: atom5, molecule: TNTMolecule)
        let conn10 = cylinderBetweenNodes(atom4, endNode: atom10, molecule: TNTMolecule)
        let conn11 = cylinderBetweenNodes(atom19, endNode: atom1, molecule: TNTMolecule)
        let conn12 = cylinderBetweenNodes(atom6, endNode: atom12, molecule: TNTMolecule)
        let conn13 = cylinderBetweenNodes(atom13, endNode: atom14, molecule: TNTMolecule)
        let conn14 = cylinderBetweenNodes(atom13, endNode: atom15, molecule: TNTMolecule)
        let conn15 = cylinderBetweenNodes(atom16, endNode: atom17, molecule: TNTMolecule)
        let conn16 = cylinderBetweenNodes(atom16, endNode: atom18, molecule: TNTMolecule)
        let conn17 = cylinderBetweenNodes(atom19, endNode: atom20, molecule: TNTMolecule)
        let conn18 = cylinderBetweenNodes(atom19, endNode: atom21, molecule: TNTMolecule)
        let conn19 = cylinderBetweenNodes(atom8, endNode: atom7, molecule: TNTMolecule)
        let conn20 = cylinderBetweenNodes(atom8, endNode: atom9, molecule: TNTMolecule)
        let conn21 = cylinderBetweenNodes(atom8, endNode: atom11, molecule: TNTMolecule)
        return TNTMolecule
    }
    class func ptfeMolecule() -> SCNNode {
        var ptfeMolecule = SCNNode()
        return ptfeMolecule
    }
    class func nodeWithAtom(atom: SCNGeometry, molecule: SCNNode, position: SCNVector3) -> SCNNode {
        let node = SCNNode(geometry: atom)
        node.position = position
        molecule.addChildNode(node)
        return node
    }
    class func cylinderBetweenNodes(startNode: SCNNode, endNode: SCNNode, molecule: SCNNode) -> SCNNode {
        let startPosition = startNode.position
        let endPosition = endNode.position
        let defaultCylinderVector = SCNVector3Make(0, 1, 0)
        let cylinderVector = makeCylinderVector(startPosition, endPosition: endPosition)
        let length = magnitude(cylinderVector)
        let cylinderGeometry = SCNCylinder(radius: 0.4, height:(CGFloat)(length))
        cylinderGeometry.firstMaterial!.diffuse.contents = UIColor.whiteColor()
        cylinderGeometry.firstMaterial!.specular.contents = UIColor.whiteColor()
        let cylinderNode = SCNNode(geometry: cylinderGeometry)
        cylinderNode.position = SCNVector3Make((startPosition.x + endPosition.x)/2, (startPosition.y + endPosition.y)/2, (startPosition.z + endPosition.z)/2)
        let rotationVector = ViewController.crossProduct(SCNVector3Make(startPosition.x - endPosition.x, startPosition.y - endPosition.y, startPosition.z - endPosition.z), vectorB: SCNVector3Make(0, 1, 0))
        let rotationAngle = acos(dotProduct(cylinderVector, vectorB: defaultCylinderVector)/(magnitude(cylinderVector) * magnitude(defaultCylinderVector)))
        cylinderNode.rotation = SCNVector4Make(rotationVector.x, rotationVector.y, rotationVector.z, rotationAngle)
        molecule.addChildNode(cylinderNode)
        return cylinderNode
    }
    class func makeCylinderVector(startPosition: SCNVector3, endPosition: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(endPosition.x - startPosition.x, endPosition.y - startPosition.y, endPosition.z - startPosition.z)
    }
    class func crossProduct(vectorA: SCNVector3, vectorB: SCNVector3) -> SCNVector3 {
        let x = vectorA.y * vectorB.z - vectorA.z * vectorB.y
        let y = vectorA.z * vectorB.x - vectorA.x * vectorB.z
        let z = vectorA.x * vectorB.y - vectorA.y * vectorB.x
        return SCNVector3Make(x, y, z)
    }
    class func magnitude(vector: SCNVector3) -> Float {
        return sqrt( pow(vector.x,2) + pow(vector.y,2) + pow(vector.z,2) )
    }
    class func dotProduct(vectorA: SCNVector3, vectorB: SCNVector3) -> Float {
        return vectorA.x * vectorB.x + vectorA.y * vectorB.y + vectorA.z * vectorB.z
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}