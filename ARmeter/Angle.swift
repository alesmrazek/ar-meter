//
//  Angle.swift
//  ARmeter
//
//  Created by mojavevirtual on 1/31/19.
//  Copyright © 2019 mrazekales. All rights reserved.
//

import SceneKit
import ARKit

/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// ANGLE UNITS ////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
enum AngleUnit {
    case radian
    case degree
    
    // konstanty pro prevody jednotek
    var fator: Float {
        switch self {
        case .radian:
            return ( 1 )
        case .degree:
            return ( 180 / .pi )
        }
    }
    // zkratky jednotek
    var unit: String {
        switch self {
        case .radian:
            return " rad"
        case .degree:
            return " °"
        }
    }
    // cely nazev jednotek
    var title: String {
        switch self {
        case .radian:
            return "radians"
        case .degree:
            return "degrees"
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// ANGLE CLASS ////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

final class Angle {
    fileprivate var color: UIColor = myRedColor
    
    fileprivate let sceneView: ARSCNView!
    
    fileprivate var text: SCNText!      // promenna pro text
    fileprivate var textNode: SCNNode!  // promenna pro pozici textu
    
    
    fileprivate let unitAngle: AngleUnit!   // linkovani vyctu jednotek uhlu
    
    // inicializace
    init(sceneView: ARSCNView,  unitA: AngleUnit) {
        self.sceneView = sceneView
        
        self.unitAngle = unitA
        
        // nastaveni textu
        text = SCNText(string: "", extrusionDepth: 0.1) // extrusionDepth je velikost textu v ose z
        text.font = .systemFont(ofSize: 7)  // velikost textu
        text.firstMaterial?.diffuse.contents = color    // barva
        text.alignmentMode  = CATextLayerAlignmentMode.center.rawValue   // zarovnani na stred
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue   // urcuje jak bude zkraceny priliz dlouhy text
        text.firstMaterial?.isDoubleSided = true    // urcuje zna ma scenekit vykreslovat predni i zadni plochy povrchu
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()    // vytvoreni Nodu pro text
        textNode?.addChildNode(textWrapperNode)  // prirazeni child Nodu
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView) // pohledove nastaveni
        constraint.isGimbalLockEnabled = true
        textNode?.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode!) // vlozeni do sceny
    }
    
    // update uhlu do sceny
    func update(to anglee: Float, to position: SCNVector3) {
        textNode.removeFromParentNode()
        text.string = angle(to: anglee)  // prirazeni informaci o vzdalenosti do textu
        textNode.position = position
        
        sceneView.scene.rootNode.addChildNode(textNode!) // prirazeni child Nodu
    }
    
    // vraci string format vydalenosti
    func angle(to angle: Float) -> String {
        return String(format: "%.2f%@", angle * unitAngle.fator, unitAngle.unit)
    }
    
    
    // onstranovani z rodicovskych Nodu aby se mohla merit nova vzdalenost
    func removeFromParentNode() {
        textNode.removeFromParentNode()
        
    }
}
