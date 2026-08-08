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

    @Test func restoreBackup_fallsBackWhenNewestFileIsCorrupt() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        struct Payload: Codable, Equatable, Sendable { let marker: String }
        try await service.performBackup(Payload(marker: "valid"), fileType: .data)

        let corruptURL = root
            .appendingPathComponent("data", isDirectory: true)
            .appendingPathComponent("dataBackup-newest.backup")
        try Data("not-json".utf8).write(to: corruptURL, options: .atomic)

        let futureDate = Date().addingTimeInterval(60)
        try FileManager.default.setAttributes(
            [.modificationDate: futureDate],
            ofItemAtPath: corruptURL.path
        )

        let restored = try service.restoreBackup(Payload.self, fileType: .data)
        #expect(restored.marker == "valid")
        #expect(service.listBackupFiles(for: .data).count == 2)
    }

    @Test func performBackup_retainsExactlyTenNewestFiles() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        for value in 0..<12 {
            try await service.performBackup(value, fileType: .data)
        }

        #expect(service.listBackupFiles(for: .data).count == 10)
    }

    @Test func concurrentBackupsDoNotOverwriteEachOther() async throws {
        let root = try makeIsolatedBackupRoot()
        defer { try? FileManager.default.removeItem(at: root) }

        let service = BackupService(documentsDirectoryOverride: root)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for value in 0..<8 {
                group.addTask {
                    try await service.performBackup(value, fileType: .data)
                }
            }
            try await group.waitForAll()
        }

        #expect(service.listBackupFiles(for: .data).count == 8)
    }
}
