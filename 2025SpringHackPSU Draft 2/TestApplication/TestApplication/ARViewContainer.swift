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

        arView.debugOptions = []

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
        var isPaused = false
        var score: Int = 0
        var shotsFired: Int = 0
        var hits: Int = 0

        override init() {
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(fireShot), name: .fireShotNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(togglePause(_:)), name: .pauseToggledNotification, object: nil)
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors.compactMap({ $0 as? ARPlaneAnchor }) {
                if let planeID = classifyPlane(anchor: anchor) {
                    print("Plane \(planeID) added")
                    planeAnchors.append(anchor)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.spawnRandomTarget()
            }
        }

        func classifyPlane(anchor: ARPlaneAnchor) -> Int? {
            let normal = anchor.transform.columns.2
            if abs(normal.y) > 0.9 {
                return normal.y < 0 ? 100 : 200
            } else {
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

        @objc func togglePause(_ notification: Notification) {
            guard let paused = notification.object as? Bool, let arView = arView else { return }

            isPaused = paused

            if paused {
                arView.snapshot(saveToHDR: false) { image in
                    if let image = image {
                        NotificationCenter.default.post(name: .pauseSnapshotReady, object: image)
                    }
                }
                arView.session.pause()
                print("Game paused.")
            } else {
                let config = ARWorldTrackingConfiguration()
                config.planeDetection = [.horizontal, .vertical]
                if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                    config.sceneReconstruction = .mesh
                }
                if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
                    config.frameSemantics.insert(.sceneDepth)
                }
                arView.session.run(config, options: [])
                print("Game resumed.")
            }
        }

        @objc func fireShot() {
            guard !isPaused else {
                print("Shot ignored: game is paused.")
                return
            }

            guard let arView = arView else { return }

            shotsFired += 1

            let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

            if let rayResult = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .any).first {
                let rayOrigin = arView.cameraTransform.translation
                let rayDirection = normalize(rayResult.worldTransform.translation - rayOrigin)

                if let entityHit = arView.scene.raycast(origin: rayOrigin, direction: rayDirection, length: 10.0, query: .all).first(where: { $0.entity.name == "target" }) {
                    if let anchorEntity = entityHit.entity.anchor as? AnchorEntity {
                        anchorEntity.removeFromParent()
                        activeTargetAnchors.removeAll(where: { $0 == anchorEntity })
                        hits += 1
                        score += 100
                        print("Target hit and removed")

                        // Post updated stats
                        postScoreUpdate()
                    }
                } else {
                    postScoreUpdate() // Even if missed
                }
            }
        }

        func postScoreUpdate() {
            let accuracy = shotsFired > 0 ? (Double(hits) / Double(shotsFired)) * 100.0 : 0
            let info: [String: Any] = [
                "score": score,
                "shotsFired": shotsFired,
                "hits": hits,
                "accuracy": accuracy
            ]
            NotificationCenter.default.post(name: .scoreUpdatedNotification, object: nil, userInfo: info) // <-- Correct notification
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
