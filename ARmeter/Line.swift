//
//  Line.swift
//  ARmeter
//
//  Created by mojavevirtual on 1/31/19.
//  Copyright © 2019 mrazekales. All rights reserved.
//

import SceneKit
import ARKit

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// DISTANCE UNITS //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
enum DistanceUnit {
    case centimeter
    case inch
    // prepoctove konstanty
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0    // defaultne je v metrech, 1m = 100cm
        case .inch:
            return 39.3700787   // 1m = 39.3700787 inches
        }
    }
    // zkratky jednotek
    var unit: String {
        switch self {
        case .centimeter:
            return " cm"
        case .inch:
            return " inch"
        }
    }
    // textova reprezentace
    var title: String {
        switch self {
        case .centimeter:
            return "centimeters"
        case .inch:
            return "inches"
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// LINE CLASS ////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

final class Line {
    fileprivate var color: UIColor = .white
    
    fileprivate let sceneView: ARSCNView!
    
    fileprivate let startVector: SCNVector3!
    fileprivate var startNode: SCNNode! // promenna pro pocatecni bod
    fileprivate var endNode: SCNNode!   // promenna pro koncovy bod
    fileprivate var text: SCNText!      // promenna pro text
    fileprivate var textNode: SCNNode!  // promenna pro pozici textu
    fileprivate var lineNode: SCNNode?  // promenna pro pozici usecky
    
    fileprivate let unit: DistanceUnit!     // linkovani vyctu jednotek delky
    
    // inicializace
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        // vytvoreni a definice bodu
        let dot = SCNSphere(radius: 0.9)
        dot.firstMaterial?.diffuse.contents = color // barva bodu
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true // urcuje zna ma scenekit vykreslovat predni i zadni plochy povrchu
        
        // prirazeni vzhledu k pocatecnimu bodu
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)    // vlozeni do sceny
        
        // prirazeni vzhledu k bodu
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        // nastaveni textu
        text = SCNText(string: "", extrusionDepth: 0.1) // extrusionDepth je velikost textu v ose z (hloubka textu)
        text.font = .systemFont(ofSize: 7)  // velikost textu
        text.firstMaterial?.diffuse.contents = color    // barva
        text.alignmentMode  = CATextLayerAlignmentMode.center.rawValue    // zarovnani na stred
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue   // urcuje jak bude zkraceny priliz dlouhy text
        text.firstMaterial?.isDoubleSided = true    // urcuje zna ma scenekit vykreslovat predni i zadni plochy povrchu
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()    // vytvoreni Nodu pro text
        textNode.addChildNode(textWrapperNode)  // prirazeni child Nodu
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView) // pohledove nastaveni
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode) // vlozeni do sceny
    }
    
    // update linky do sceny
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()    // onstraneni rodicovskeho Nodu aby se mohla urcit nova pozice
        lineNode = startVector.line(to: vector, color: color)   // nova pozice linky
        sceneView.scene.rootNode.addChildNode(lineNode!)    // prirazeni child Nodu
        
        text.string = distance(to: vector)  // prirazeni informaci o vzdalenosti do textu
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode) // prirazeni child Nodu
        }
    }
    
    // vraci string format vydalenosti
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    // odstranovani z rodicovskych Nodu aby se mohla merit nova vzdalenost
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
