//
//  NotificationNames.swift
//  TestApplication
//
//  Created by Chaoping Li on 3/29/25.
//

import Foundation

extension Notification.Name {
    static let fireShotNotification = Notification.Name("fireShotNotification")
    static let pauseToggledNotification = Notification.Name("pauseToggledNotification")
    static let pauseSnapshotReady = Notification.Name("pauseSnapshotReady")
    static let scoreUpdatedNotification = Notification.Name("scoreUpdatedNotification")
}