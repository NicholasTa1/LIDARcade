import Foundation
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics.insert(.sceneDepth)
        }
        config.planeDetection = [.horizontal, .vertical]
        arView.session.delegate = context.coordinator
        arView.session.run(config)

        arView.debugOptions = [.showSceneUnderstanding, .showAnchorOrigins]

        context.coordinator.arView = arView
        context.coordinator.setupCrosshairButton()
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView?
        var planeAnchors: [ARPlaneAnchor] = []
        var activeTargetAnchors: [AnchorEntity] = []

        override init() {
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(fireShot), name: .fireShotNotification, object: nil)
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors.compactMap({ $0 as? ARPlaneAnchor }) {
                if let planeID = classifyPlane(anchor: anchor) {
                    print("Plane \(planeID) added")
                    planeAnchors.append(anchor)
                }
            }

            // Spawn one target on first plane add for now
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.spawnRandomTarget()
            }
        }

        func classifyPlane(anchor: ARPlaneAnchor) -> Int? {
            let normal = anchor.transform.columns.2
            if abs(normal.y) > 0.9 {
                return normal.y < 0 ? 100 : 200 // Floor or ceiling
            } else {
                // For simplicity, assign static IDs to first 4 walls
                switch planeAnchors.count % 4 {
                case 0: return 300
                case 1: return 400
                case 2: return 500
                case 3: return 600
                default: return nil
                }
            }
        }

        func gridPosition(for index: Int, in anchor: ARPlaneAnchor) -> SIMD3<Float> {
            let row = index / 10
            let col = index % 10

            let size = anchor.extent
            let center = anchor.center

            let cellSizeX = size.x / 10.0
            let cellSizeZ = size.z / 10.0

            let x = center.x - size.x / 2 + (Float(col) + 0.5) * cellSizeX
            let z = center.z - size.z / 2 + (Float(row) + 0.5) * cellSizeZ

            return SIMD3<Float>(x, 0, z)
        }

        func spawnRandomTarget() {
            guard !planeAnchors.isEmpty else { return }

            // Hard cap: Don't spawn if 10 or more targets are already present
            if activeTargetAnchors.count >= 10 { return }

            let rand = Int.random(in: 100...699)
            let planeID = (rand / 100) * 100
            let gridIndex = rand % 100

            guard let anchor = planeAnchors.first(where: { classifyPlane(anchor: $0) == planeID }) else {
                print("No matching plane for ID \(planeID)")
                return
            }

            let localPos = gridPosition(for: gridIndex, in: anchor)
            let worldTransform = anchor.transform
            let worldPos = (worldTransform * SIMD4<Float>(localPos, 1)).xyz

            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let target = ModelEntity(mesh: mesh, materials: [material])
            target.name = "target"
            target.generateCollisionShapes(recursive: true)
            target.position = worldPos

            let anchorEntity = AnchorEntity(world: worldPos)
            anchorEntity.addChild(target)

            arView?.scene.addAnchor(anchorEntity)
            activeTargetAnchors.append(anchorEntity)
        }


        func setupCrosshairButton() {
            guard let arView = arView else { return }

            let button = UIButton(type: .system)
            button.frame = CGRect(x: arView.bounds.midX - 30, y: arView.bounds.height - 100, width: 60, height: 60)
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            button.layer.cornerRadius = 30
            button.setImage(UIImage(systemName: "scope"), for: .normal)
            button.tintColor = .white
            button.addTarget(self, action: #selector(fireShot), for: .touchUpInside)

            arView.addSubview(button)
        }

        @objc func fireShot() {
            guard let arView = arView else { return }

            let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

            if let rayResult = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .any).first {
                let rayOrigin = arView.cameraTransform.translation
                let rayDirection = normalize(rayResult.worldTransform.translation - rayOrigin)

                if let entityHit = arView.scene.raycast(origin: rayOrigin, direction: rayDirection, length: 10.0, query: .all).first(where: { $0.entity.name == "target" }) {
                    
                    if let anchorEntity = entityHit.entity.anchor as? AnchorEntity {
                        anchorEntity.removeFromParent()
                        activeTargetAnchors.removeAll(where: { $0 == anchorEntity })
                        print("Target hit and removed")
                    }
                }
            }
        }
    }
}

extension simd_float4x4 {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

extension Notification.Name {
    static let fireShotNotification = Notification.Name("fireShotNotification")
}

extension Transform {
    var translation: SIMD3<Float> {
        return matrix.columns.3.xyz
    }
}

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
