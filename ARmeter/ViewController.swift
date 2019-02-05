//
//  ViewController.swift
//  ARmeter
//
//  Created by mrazekales on 1/31/19.
//  Copyright © 2019 mrazekales. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreData

public var myBlueColor = UIColor(displayP3Red: 6/255, green: 117/255, blue: 237/255, alpha: 1.0)
public var myRedColor = UIColor(displayP3Red: 225/255, green: 0.0, blue: 8/255, alpha: 1.0)
public var myGreenColor = UIColor(displayP3Red: 44/255, green: 222/255, blue: 0.0, alpha: 1.0)
public var myYellowColor = UIColor(displayP3Red: 255/255, green: 212/255, blue: 81/255, alpha: 1.0)


class ViewController: UIViewController, ARSCNViewDelegate {

    // linkovani objektu ze storyboardu
    @IBOutlet var sceneView: ARSCNView!                     // scena
    @IBOutlet weak var loading: UIActivityIndicatorView!    // loading indicator
    @IBOutlet weak var infoLabel: UILabel!                  // label nad pointrem
    @IBOutlet weak var unitsButton: UIButton!               // tlacitko jednotek
    @IBOutlet weak var resetButton: UIButton!               // tlacitko na reset
    @IBOutlet weak var targetPointer: UIImageView!          // tercik pro mireni (pointer)
    @IBOutlet weak var angleButton: UIButton!               // tlacitko na zapnuti/vypnuti uhlu
    
    // potrebne promenne
    var vectorZero = SCNVector3()
    var startPoint = SCNVector3()
    var endPoint = SCNVector3()
    
    // promenne pro zjednoduseni vypoctu uhlu
    var endOld = SCNVector3()
    var startOld = SCNVector3()
    
    // bool pro urceni zda se meri
    var measurement = false
    var isAngle = false
    var measureAngle = false
    
    // pole usecek/uhlu
    var lines: [Line] = []
    var angles: [Angle] = []
    
    // soucasna usecka/uhel
    var currentLine: Line?
    var currentAngle: Angle?
    
    // defaultni jednotky
    var unit: DistanceUnit = .centimeter    // jednotka pro vzdalenosti
    var unitAngle: AngleUnit = .degree      // jednotka pro uhly
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        sceneView.showsStatistics = false
        sceneView.delegate = self
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]  // debug nastaveni - jsou videt orientacni body
        
        // vytvoreni configurace  a ARsession
        let configuration: ARConfiguration = ARWorldTrackingConfiguration()
        
        // spusteni sceny
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////// FUNCTIONS ///////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
//    func saveToCoreData(name: String, value: Double, units: String){
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let userEntity = NSEntityDescription.entity(forEntityName: "ValueRecord", in: managedContext)!
//        let record = NSManagedObject(entity: userEntity, insertInto: managedContext)
//
//        record.setValue(name, forKeyPath: "name")
//        record.setValue(String(value), forKey: "value")
//        record.setValue(units, forKey: "units")
//
//        do {
//            try managedContext.save()
//            print("Saved to Core Data")
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
    
    func deleteFromCoreData(){
        
    }
    
    func loadFromCoreData(){
        
    }
    
    // funkce pro nastaveni pri prvotni skenovani
    func setup(){
        targetPointer.isHidden = true           // skryti zamerovaciho terciku(pointeru)
        loading.startAnimating()                // zapnuti animace loading indikatoru
        resetButton.isHidden = true             // schovani tlacitka pro reset
        unitsButton.isHidden = true             // schovani tlacitka pro jednotky
        angleButton.isHidden = true             // schovani tlacitka pro vypinani uhlu
        infoLabel.text = "Scanning ..."         // nastaveni textu v labelu
        resetMeasuredValues()                   // funkce pro vynulovaci vsech namerenich hodnot
    }
    
    // funkce pro vynulovaci vsech namerenich hodnot
    func resetMeasuredValues() {
        measurement = false
        measureAngle = false
        startOld = startPoint
        endOld = endPoint
        
        startPoint = SCNVector3()
        endPoint =  SCNVector3()
    }
    
    // funkce se spusti pri doteku obrazovky
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetMeasuredValues()
        measurement = true
        targetPointer.image = UIImage(named: "yellowTarget")
    }
    
    // funkce se spusti pri zruseni doteku obrazovky
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        measurement = false
        targetPointer.image = UIImage(named: "whiteTarget")   // zmena terciku na bily
        
        if (currentLine != nil){
            let line = currentLine
            lines.append(line!)  // pridani soucasne usecky do pole
            let linescount = lines.count
            
            if (linescount>1 && isAngle == true){
                let angle = currentAngle // // pridani soucasneho uhlu do pole
                angles.append(angle!)
            }
            
            currentLine = nil
            currentAngle = nil
            resetButton.isHidden = false
        }
    }
    
    // funkce pro vypocet uhlu
    func angle2vector( vectorStart1: SCNVector3,vectorEnd1: SCNVector3, vectorStart2: SCNVector3, vectorEnd2: SCNVector3) -> Float {
        
        // slozky vector1
        let x1 = vectorStart1.x - vectorEnd1.x
        let y1 = vectorStart1.y - vectorEnd1.y
        let z1 = vectorStart1.z - vectorEnd1.z
        let distance1 = sqrtf((x1*x1+(y1*y1)+(z1*z1)))   // delka vektoru
        
        // slozky vector2
        let x2 = vectorStart2.x - vectorEnd2.x
        let y2 = vectorStart2.y - vectorEnd2.y
        let z2 = vectorStart2.z - vectorEnd2.z
        let distance2 = sqrtf((x2*x2+(y2*y2)+(z2*z2)))   // delka vektoru
        
        // vypocet
        let angle = ( acos( -(( (x1*x2)+(y1*y2)+(z1*z2) ) / ( distance1 * distance2 ))))   // uhel v radianech
        
        return angle
    }
    
    // porovnani zda jsou dva vektory stejne
    func vector3compare(vector1: SCNVector3, vector2: SCNVector3) -> Bool {
        
        return (vector1.x == vector2.x) && (vector1.y == vector2.y) && (vector1.z == vector2.z)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////// BUTTONS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////

    @IBAction func unitsClick(_ sender: Any) {
        // vytvoreni menu s nmoznou zmenou jednotek uhlu a vzdalenosti
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var distUnit = "distance:  " + DistanceUnit.centimeter.title
        var angUnit = "angle:  " + AngleUnit.degree.title
        
        if self.unit == .inch{
            distUnit = "distance:  " + DistanceUnit.inch.title
        }
        if self.unitAngle == .radian{
            angUnit = "angle:  " + AngleUnit.radian.title
        }
        
        menu .addAction(UIAlertAction(title: distUnit, style: .default) { [weak self] _ in
            switch (self?.unit) {
            case .centimeter?:
                self?.unit = .inch
            case .inch?:
                self?.unit = .centimeter
            case .none: break
            }
        })
        
        menu .addAction(UIAlertAction(title: angUnit, style: .default) { [weak self] _ in
            switch (self?.unitAngle) {
            case .degree?:
                self?.unitAngle = .radian
            case .radian?:
                self?.unitAngle = .degree
            case .none: break
            }
        })
        
        let cancelAction = UIAlertAction(title: "close", style: .cancel, handler: nil)
        cancelAction.setValue(myYellowColor, forKey: "titleTextColor")
        //cancelAction.setValue(UIColor.black, forKey: "backgroundColor")

        menu .addAction(cancelAction)
        
        // change the background color
        menu.view.tintColor = .black
        let subview = (menu.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = .white
        
        present(menu, animated: false, completion: nil)
    }
    
    @IBAction func resetClick(_ sender: Any) {
        if (resetButton.isHidden == false){
            
            resetButton.isHidden = true
            for line in lines {
                line.removeFromParentNode() // odstaraneni
            }
            
            for angle in angles {
                angle.removeFromParentNode() // odstaraneni
            }
            lines.removeAll() // vycisteni pole
            angles.removeAll() // vycisteni pole
        }
    }
    
    @IBAction func angleClick(_ sender: Any) {
        if (self.isAngle == false){
            self.angleButton.setTitle("ANGLE:  ON", for: .normal)
            self.angleButton.backgroundColor = myYellowColor
            self.angleButton.setTitleColor(.black, for: .normal)
            self.isAngle = true
        }
        else{
            self.angleButton.setTitle("ANGLE: OFF", for: .normal)
            self.angleButton.backgroundColor = .black
            self.angleButton.setTitleColor(myYellowColor, for: .normal)
            self.isAngle = false
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////// ARSCNViewDelegate /////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
    
    // prvotni skenovani prostredi
    func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(position: view.center) else { return } // urceni pozice v realnem svete na stredu obazovky
        
        targetPointer.isHidden = false
        unitsButton.isHidden = false
        angleButton.isHidden = false
        loading.stopAnimating() // zastaveni animace loading indikatoru
        loading.isHidden = true
        
        if (lines.isEmpty && angles.isEmpty) {
            infoLabel.text = "Touch to measure"
        }
        
        if measurement {
            
            if (vector3compare(vector1: startPoint, vector2: vectorZero)){
                
                let lc = lines.count
                if (lc>0 && isAngle){
                    measureAngle = true
                    startPoint = endOld
                    currentAngle = Angle(sceneView: sceneView, unitA: unitAngle)
                }
                else{
                    startPoint = worldPosition
                }
                currentLine = Line(sceneView: sceneView, startVector: startPoint, unit: unit)
            }
            endPoint = worldPosition
            
            if measureAngle{
                
                let anglee =  angle2vector( vectorStart1: startOld, vectorEnd1: endOld, vectorStart2: startPoint, vectorEnd2: endPoint)
                let textAnglepos = position(vectorEnd1: endOld, vectorStart2: endOld)
                
                currentAngle?.update(to: anglee, to: textAnglepos)
            }
            
            currentLine?.update(to: endPoint)                                       // pridani koncoveho bodu usecky
            infoLabel.text = currentLine?.distance(to: endPoint) ?? "Calculation"   // vypsani vzdalenosti do labelu
            
        }
    }
    
    // pozice pro text uhlu
    func position (vectorEnd1: SCNVector3, vectorStart2: SCNVector3) -> SCNVector3{
        
        let x = (vectorEnd1.x+vectorStart2.x)/2.0
        let y = (vectorEnd1.y+vectorStart2.y)/2.0
        let z = (vectorEnd1.z+vectorStart2.z)/2.0
        
        return SCNVector3(x,y,z)
    }
}

///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// ARSCNView extension ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

extension ARSCNView {
    
    // ziskani pozice v realnem svete
    func realWorldVector(position: CGPoint) -> SCNVector3? {
        
        let results = self.hitTest(position, types: [.featurePoint])
        guard let result = results.first else { return nil }
        
        // vraci vektor pozice
        return SCNVector3.positionFromTransform(result.worldTransform)
    }
}

///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// SCNVector3 extension ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

extension SCNVector3 {
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    // funkce pro vypocet vzdalenosti
    func distance(from vector: SCNVector3) -> Float {
        // rozdil slozek
        let x = self.x - vector.x
        let y = self.y - vector.y
        let z = self.z - vector.z
        
        // vypocet vzdalenost = tretiodmocnina(x^2+y^2+z^2)
        let distance = sqrtf((x*x+(y*y)+(z*z)))
        
        return distance
    }
    
    // rozsireni pro kresleni usecek
    func line(to vector: SCNVector3, color: UIColor = .white) -> SCNNode {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [self, vector])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        return node
    }
}
