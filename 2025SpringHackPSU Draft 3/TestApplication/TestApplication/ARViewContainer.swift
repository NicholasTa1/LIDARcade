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

        // Re-enable debug visualization to help with development
        arView.debugOptions = [.showSceneUnderstanding, .showAnchorOrigins]

        context.coordinator.arView = arView
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

            // Spawn targets after a short delay when planes are detected
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
            guard !planeAnchors.isEmpty, !isPaused else { return }

            // Hard cap: Don't spawn if 10 or more targets are already present
            if activeTargetAnchors.count >= 10 { return }

            let rand = Int.random(in: 100...699)
            let planeID = (rand / 100) * 100
            let gridIndex = rand % 100

            guard let anchor = planeAnchors.first(where: { classifyPlane(anchor: $0) == planeID }) else {
                print("No matching plane for ID \(planeID)")
                // Try again with a different random position
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.spawnRandomTarget()
                }
                return
            }

            let localPos = gridPosition(for: gridIndex, in: anchor)
            let worldTransform = anchor.transform
            let worldPos = (worldTransform * SIMD4<Float>(localPos, 1)).xyz

            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let target = ModelEntity(mesh: mesh, materials: [material])
            target.name = "target" // This name is critical for hit detection
            target.generateCollisionShapes(recursive: true)
            target.position = worldPos

            let anchorEntity = AnchorEntity(world: worldPos)
            anchorEntity.addChild(target)

            arView?.scene.addAnchor(anchorEntity)
            activeTargetAnchors.append(anchorEntity)
            
            print("Target spawned at position: \(worldPos)")
            
            // Spawn another target after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.spawnRandomTarget()
            }
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
                
                // Resume target spawning
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.spawnRandomTarget()
                }
            }
        }

        @objc func fireShot() {
            guard !isPaused, let arView = arView else { return }

            shotsFired += 1
            print("Shot fired! Total shots: \(shotsFired)")

            let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)

            // First raycast to get distance to visible surface
            if let rayResult = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .any).first {
                let rayOrigin = arView.cameraTransform.translation
                let rayDirection = normalize(rayResult.worldTransform.translation - rayOrigin)
                
                // Debug visualization of ray
                print("Ray from: \(rayOrigin) in direction: \(rayDirection)")

                // Second raycast for entity hit detection against the 3D scene
                let entityHits = arView.scene.raycast(origin: rayOrigin, direction: rayDirection, length: 10.0, query: .all)
                
                // Debug all hits
                if !entityHits.isEmpty {
                    print("Hit \(entityHits.count) entities")
                    entityHits.forEach { hit in
                        print("Hit entity named: \(hit.entity.name)")
                    }
                } else {
                    print("No entities hit")
                }
                
                // Find a target entity in the hits
                if let targetHit = entityHits.first(where: { $0.entity.name == "target" }) {
                    if let anchorEntity = targetHit.entity.anchor as? AnchorEntity {
                        // Target hit!
                        anchorEntity.removeFromParent()
                        activeTargetAnchors.removeAll(where: { $0 == anchorEntity })
                        hits += 1
                        score += 100
                        print("Target hit and removed! Score: \(score), Hits: \(hits)")

                        // Spawn a new target after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.spawnRandomTarget()
                        }
                    }
                }
                
                // Always update score display (hit or miss)
                postScoreUpdate()
            } else {
                print("No surface hit by initial raycast")
                postScoreUpdate() // Even if no surface was hit
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
            NotificationCenter.default.post(name: .scoreUpdatedNotification, object: nil, userInfo: info)
            print("Posted score update: score=\(score), accuracy=\(accuracy)%")
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