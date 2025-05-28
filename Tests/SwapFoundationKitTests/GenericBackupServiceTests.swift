import Testing
@testable import SwapFoundationKit
import Foundation

private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}

struct GenericBackupServiceTests {
    static let testDirectory = "TestBackups"
    static let filePrefix = "testModel"
    static let service = GenericBackupService<TestModel>(
        directoryName: testDirectory,
        maxFileCount: 3,
        fileNameProvider: GenericBackupService<TestModel>.timestampedFileName(prefix: filePrefix)
    )

    static func cleanup() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let directoryURL = documentsDirectory.appendingPathComponent(testDirectory)
        try? FileManager.default.removeItem(at: directoryURL)
    }

    @Test static func testBackupAndListAndRestore() async throws {
        cleanup()
        let model = TestModel(id: 1, name: "A")
        await service.performBackup(model)
        let backups = service.listBackups()
        #expect(backups.count == 1)
        let restored = try service.restore(from: backups[0])
        #expect(restored == model)
        cleanup()
    }

    @Test static func testRetention() async throws {
        cleanup()
        for i in 1...5 {
            let model = TestModel(id: i, name: "N\(i)")
            await service.performBackup(model)
            // Sleep to ensure unique timestamps
            usleep(100_000)
        }
        let backups = service.listBackups()
        #expect(backups.count == 3)
        // The latest should be id 5
        let latest = try service.restore(from: backups[0])
        #expect(latest.id == 5)
        cleanup()
    }
} 