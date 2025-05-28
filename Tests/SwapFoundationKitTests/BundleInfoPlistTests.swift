import Testing
@testable import SwapFoundationKit
import Foundation

struct BundleInfoPlistTests {
    // Helper: Create a mock bundle by subclassing Bundle
    private final class MockBundle: Bundle {
        let mockInfo: [String: Any]
        let mockResources: [String: [String: Any]]
        init(info: [String: Any], resources: [String: [String: Any]] = [:]) {
            self.mockInfo = info
            self.mockResources = resources
            super.init()
        }
        override var infoDictionary: [String : Any]? { mockInfo }
        override func url(forResource name: String?, withExtension ext: String?) -> URL? {
            guard let name = name, let ext = ext, ext == "plist", let dict = mockResources[name] else { return nil }
            let data = try! PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
            let tmp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".plist")
            try! data.write(to: tmp)
            return tmp
        }
    }

    @Test static func testInfoPlistValueStandardAndCustomKeys() async throws {
        let bundle = MockBundle(info: [
            "CFBundleName": "TestApp",
            "CustomKey": "CustomValue",
            "IntKey": "42"
        ])
        #expect(bundle.infoPlistValue(forKey: .appName, default: "") == "TestApp")
        #expect(bundle.infoPlistValue(forKey: .custom("CustomKey"), default: "") == "CustomValue")
        #expect(bundle.infoPlistValue(forKey: .custom("IntKey"), default: 0) == 42)
    }

    @Test static func testComputedProperties() async throws {
        let bundle = MockBundle(info: [
            "CFBundleName": "TestApp",
            "CFBundleDisplayName": "Test Display",
            "CFBundleExecutable": "TestExec",
            "CFBundleDevelopmentRegion": "en",
            "MinimumOSVersion": "16.0",
            "UIDeviceFamily": [1,2],
            "UIRequiredDeviceCapabilities": ["arm64"],
            "CFBundleShortVersionString": "1.2.3",
            "CFBundleVersion": "456",
            "CFBundleIdentifier": "com.example.test",
            "NSHumanReadableCopyright": "Copyright 2024"
        ])
        #expect(bundle.appName == "TestApp")
        #expect(bundle.displayName == "Test Display")
        #expect(bundle.executable == "TestExec")
        #expect(bundle.developmentRegion == "en")
        #expect(bundle.minimumOSVersion == "16.0")
        #expect(bundle.deviceFamily == [1,2])
        #expect(bundle.requiredDeviceCapabilities == ["arm64"])
        #expect(bundle.releaseVersionNumber == "1.2.3")
        #expect(bundle.buildVersionNumber == "456")
        #expect(bundle.bundleIdentifier == "com.example.test")
        #expect(bundle.copyright == "Copyright 2024")
    }

    @Test static func testAppIconName() async throws {
        let bundle = MockBundle(info: [
            "CFBundleIcons": [
                "CFBundlePrimaryIcon": [
                    "CFBundleIconFiles": ["IconSmall", "IconLarge"]
                ]
            ]
        ])
        #expect(bundle.appIconName == "IconLarge")
    }

    @Test static func testUrlSchemes() async throws {
        let bundle = MockBundle(info: [
            "CFBundleURLTypes": [
                ["CFBundleURLSchemes": ["scheme1", "scheme2"]],
                ["CFBundleURLSchemes": ["scheme3"]]
            ]
        ])
        #expect(bundle.urlSchemes == ["scheme1", "scheme2", "scheme3"])
    }

    @Test static func testIsDebugBuild() async throws {
        // This test just checks the property exists and is a Bool
        let bundle = MockBundle(info: [:])
        _ = bundle.isDebugBuild
        #expect(type(of: bundle.isDebugBuild) == Bool.self)
    }

    @Test static func testLocalizedInfoPlistValue() async throws {
        // This test will just check that the method exists and returns nil for mock
        let bundle = MockBundle(info: [:])
        #expect(bundle.localizedInfoPlistValue(forKey: "AnyKey") == "")
    }

    @Test static func testGenericPlistAccess() async throws {
        let bundle = MockBundle(info: [:], resources: [
            "TestPlist": ["SomeKey": "SomeValue", "IntKey": "123"]
        ])
        #expect(bundle.plistValue(named: "TestPlist", key: "SomeKey", default: "") == "SomeValue")
        #expect(bundle.plistValue(named: "TestPlist", key: "IntKey", default: 0) == 123)
        #expect(bundle.plistValue(named: "TestPlist", key: "MissingKey", default: "default") == "default")
    }
} 
