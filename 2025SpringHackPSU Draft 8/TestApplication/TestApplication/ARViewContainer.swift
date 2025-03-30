
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

        context.coordinator.arView = arView
        context.coordinator.setupTimerLabel()
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

        // Scoring
        var score: Int = 0
        var shotsFired: Int = 0
        var hits: Int = 0

        // Timer properties
        var timerLabel: UILabel?
        var gameTimer: Timer?
        var timeRemaining: Int = 20
        var isTimerRunning: Bool = false

        override init() {
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(fireShot), name: .fireShotNotification, object: nil)
        }
        
        // Setup timer label
        func setupTimerLabel() {
            guard let arView = arView else { return }
            
            let label = UILabel()
            label.frame = CGRect(x: UIScreen.main.bounds.width - 120, y: 50, width: 100, height: 40)
            label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            label.text = "20s"
                
            arView.addSubview(label)
            self.timerLabel = label
        }
                
        // Start countdown timer
        func startGameTimer() {
            guard !isTimerRunning else { return }
                
            isTimerRunning = true
            timerLabel?.isHidden = false
            timeRemaining = 20
                    
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                self.timeRemaining -= 1
                self.timerLabel?.text = "\(self.timeRemaining)s"
                        
                if self.timeRemaining <= 5 {
                    // Make timer red when time is running out
                    self.timerLabel?.textColor = .red
                }
                        
                if self.timeRemaining <= 0 {
                    self.endGame()
                }
            }
        }
                
        // End game when timer runs out
        func endGame() {
            gameTimer?.invalidate()
            gameTimer = nil
            isTimerRunning = false
            
            // Remove all targets
            for anchor in activeTargetAnchors {
                anchor.removeFromParent()
            }
            activeTargetAnchors.removeAll()
            
            // Show game over message
            DispatchQueue.main.async {
                self.showGameOverMessage()
            }
                
            // Notify about final score
            let accuracy = shotsFired > 0 ? (Double(hits) / Double(shotsFired)) * 100.0 : 0
            NotificationCenter.default.post(name: .gameOverNotification, object: nil, userInfo: [
                "score": score,
                "accuracy": accuracy,
                "hits": hits,
                "shotsFired": shotsFired
            ])
        }
                
        // Display game over message
        func showGameOverMessage() {
            guard let arView = arView else { return }
            
            let gameOverView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
            gameOverView.center = arView.center
            gameOverView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            gameOverView.layer.cornerRadius = 16
                
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 300, height: 40))
            titleLabel.text = "GAME OVER"
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                    
            let scoreLabel = UILabel(frame: CGRect(x: 0, y: 70, width: 300, height: 30))
            scoreLabel.text = "Score: \(score)"
            scoreLabel.textColor = .white
            scoreLabel.textAlignment = .center
            scoreLabel.font = UIFont.systemFont(ofSize: 20)
                    
            let accuracyLabel = UILabel(frame: CGRect(x: 0, y: 110, width: 300, height: 30))
            let accuracy = shotsFired > 0 ? (Double(hits) / Double(shotsFired)) * 100.0 : 0
            accuracyLabel.text = "Accuracy: \(Int(accuracy))%"
            accuracyLabel.textColor = .white
            accuracyLabel.textAlignment = .center
            accuracyLabel.font = UIFont.systemFont(ofSize: 20)
                    
            let playAgainButton = UIButton(type: .system)
            playAgainButton.frame = CGRect(x: 100, y: 150, width: 100, height: 40)
            playAgainButton.setTitle("Play Again", for: .normal)
            playAgainButton.tintColor = .white
            playAgainButton.backgroundColor = UIColor.systemBlue
            playAgainButton.layer.cornerRadius = 8
            playAgainButton.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
                    
            gameOverView.addSubview(titleLabel)
            gameOverView.addSubview(scoreLabel)
            gameOverView.addSubview(accuracyLabel)
            gameOverView.addSubview(playAgainButton)
                    
            arView.addSubview(gameOverView)
                    
            // Store reference to game over view for removal later
            self.gameOverView = gameOverView
        }
                
        var gameOverView: UIView?
                
        @objc func resetGame() {
            // Remove game over view
            gameOverView?.removeFromSuperview()
            gameOverView = nil
                    
            // Reset game state
            score = 0
            shotsFired = 0
            hits = 0
            timeRemaining = 20
            
            // Reset timer label
            timerLabel?.text = "20s"
            timerLabel?.textColor = .white
            timerLabel?.isHidden = true
            
            // Update score display
            NotificationCenter.default.post(name: .scoreUpdatedNotification, object: nil, userInfo: [
                "score": score,
                "accuracy": 0
            ])
                
            // Start spawning targets again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.spawnRandomTarget()
            }
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

            // Load the alien model
            guard let alienEntity = try? Entity.loadModel(named: "alien") else {
                print("Failed to load alien model")
                return
            }
            let target = alienEntity.clone(recursive: true)
            target.name = "target"
            target.generateCollisionShapes(recursive: true)
            target.position = worldPos
            target.scale = SIMD3<Float>(0.1, 0.1, 0.1)




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
        func showShootingDot() {
            guard let arView = arView else { return }

            // Create a small green dot at the center
            let dotSize: CGFloat = 20
            let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
            dotView.center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            dotView.backgroundColor = UIColor.green
            dotView.layer.cornerRadius = dotSize / 2
            arView.addSubview(dotView)

            // Animate it fading out quickly
            UIView.animate(withDuration: 0.1, animations: {
                dotView.alpha = 0
            }) { _ in
                dotView.removeFromSuperview()
            }
        }







        @objc func fireShot() {
            showShootingDot()
            guard let arView = arView else { return }

            if !isTimerRunning {
                startGameTimer()
            }

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
                    }
                }
            }

            let accuracy = shotsFired > 0 ? (Double(hits) / Double(shotsFired)) * 100.0 : 0
            NotificationCenter.default.post(name: .scoreUpdatedNotification, object: nil, userInfo: [
                "score": score,
                "accuracy": accuracy
            ])
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

extension Notification.Name {
    static let gameOverNotification = Notification.Name("gameOverNotification")
}
