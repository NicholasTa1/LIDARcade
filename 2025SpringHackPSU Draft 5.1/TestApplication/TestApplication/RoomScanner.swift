//
//  RoomScanner.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

import SwiftUI
import RoomPlan
import RealityKit
import simd
import Foundation

class ScanViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    var roomCaptureSession: RoomCaptureSession!
    var roomCaptureView: RoomCaptureView!

    override func viewDidLoad() {
        super.viewDidLoad()

        roomCaptureView = RoomCaptureView(frame: view.bounds)
        view.addSubview(roomCaptureView)

        roomCaptureSession = roomCaptureView.captureSession
        roomCaptureSession.delegate = self
        roomCaptureSession.run(configuration: RoomCaptureSession.Configuration())
    }

    func captureSession(_ session: RoomCaptureSession, didEndWith room: CapturedRoom) {
        print("Room scan completed")

        for (index, wall) in room.walls.enumerated() {
            let transform = wall.transform
            let origin = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            let forward = SIMD3<Float>(transform.columns.2.x, transform.columns.2.y, transform.columns.2.z)

            let wallLength: Float = 2.0  // Estimated wall length (tweak as needed)
            let gridSpacing = wallLength / 10.0

            print("Wall \(index + 1):")
            for i in 0..<10 {
                let point = origin + forward * (Float(i) + 0.5) * gridSpacing
                print("  Grid \(i): x=\(point.x), y=\(point.y), z=\(point.z)")
            }
        }
    }
}

struct RoomScannerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScanViewController {
        return ScanViewController()
    }

    func updateUIViewController(_ uiViewController: ScanViewController, context: Context) {}
}
