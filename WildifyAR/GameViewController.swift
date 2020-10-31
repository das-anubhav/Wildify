//
//  GameViewController.swift
//  Wildify
//
//  Created by ANUBHAV DAS on 21/10/20.
//  Copyright © 2020 Captain Anubhav. All rights reserved.
//

import UIKit
import RealityKit
import Combine
import ARKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anchor = AnchorEntity(plane: .any, minimumBounds: [0.2,0.2])
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        
        for _ in 1...16 {
            
            let box = MeshResource.generateBox(width: 0.05, height: 0.002, depth: 0.05)
            let metalMaterial = SimpleMaterial(color: .systemBackground, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            
            model.generateCollisionShapes(recursive: true)
            
            cards.append(model)
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            card.position = [x*0.1, 0, z*0.1]
            anchor.addChild(card)
            
        }
        
        let boxSize: Float = 0.7
        let occulsionBoxMesh = MeshResource.generateBox(size: boxSize)
        let occulsionBox = ModelEntity(mesh: occulsionBoxMesh, materials: [OcclusionMaterial()])
        
        occulsionBox.position.y = -boxSize/2
        anchor.addChild(occulsionBox)
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "01")
            .append(ModelEntity.loadModelAsync(named: "02"))
            .append(ModelEntity.loadModelAsync(named: "03"))
            .append(ModelEntity.loadModelAsync(named: "04"))
            .append(ModelEntity.loadModelAsync(named: "05"))
            .append(ModelEntity.loadModelAsync(named: "06"))
            .append(ModelEntity.loadModelAsync(named: "07"))
            .append(ModelEntity.loadModelAsync(named: "08"))
            .collect()
            .sink(receiveCompletion: {error in
                print("error \(error)")
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                }
                objects.shuffle()
                
                for (index, object) in objects.enumerated() {
                    cards[index].addChild(object)
                    cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                }
                
                cancellable?.cancel()
            })
        
        
    }
    
    
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: arView)
        var repete:[Entity] = []
        
        if let card = arView.entity(at: tapLocation) {
            if card.transform.rotation.angle == .pi {
                var flipDownTransformation = card.transform
                flipDownTransformation.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                card.move(to: flipDownTransformation, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            }
            else {
                var flipUpTransformation = card.transform
                flipUpTransformation.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                card.move(to: flipUpTransformation, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
            }
            if repete.count >= 2 {
                var turnAroundTransform1 = repete[0].transform
                var turnAroundTransform2 = repete[1].transform
                turnAroundTransform1.rotation = simd_quatf(angle: 0,axis: [1, 0, 0])
                card.move(to: turnAroundTransform1, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
                
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
