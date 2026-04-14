/*****************************************************************************
 * BackupServiceTests.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Testing
@testable import SwapFoundationKit

struct BackupServiceTests {

    private func makeIsolatedBackupRoot() throws -> URL {
        let base = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("SwapFoundationKit-BackupServiceTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    @Test func restoreBackup_roundTripsCodablePayload() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        struct Payload: Codable, Equatable, Sendable {
            let id: Int
            let name: String
        }
        let original = Payload(id: 42, name: "round-trip")
        try await service.performBackup(original, fileType: .data)

        let restored = try service.restoreBackup(Payload.self, fileType: .data)
        #expect(restored == original)

        let listed = service.listBackupFiles(for: .data)
        #expect(listed.count == 1)
    }

    @Test func restoreBackup_returnsNewestFileWhenMultipleExist() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        struct Payload: Codable, Equatable, Sendable {
            let marker: String
        }

        try await service.performBackup(Payload(marker: "older"), fileType: .data)
        // `BackupService.FileType.fileName` uses second resolution; two backups in the same second overwrite.
        try await Task.sleep(nanoseconds: 1_100_000_000)
        try await service.performBackup(Payload(marker: "newer"), fileType: .data)

        let restored = try service.restoreBackup(Payload.self, fileType: .data)
        #expect(restored.marker == "newer")
        #expect(service.listBackupFiles(for: .data).count == 2)
    }

    @Test func restoreBackup_roundTripsEncodedDataBlob() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        let innerJSON = #"{"ok":true}"#.data(using: .utf8)!
        try await service.performBackup(innerJSON, fileType: .data)

        let restored = try service.restoreBackup(Data.self, fileType: .data)
        #expect(restored == innerJSON)
    }

    @Test func restoreBackup_throwsWhenNoBackupsExist() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        #expect(throws: BackupService.BackupError.self) {
            try service.restoreBackup(String.self, fileType: .data)
        }
    }
}
