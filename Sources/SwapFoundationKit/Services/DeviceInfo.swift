import UIKit

// MARK: - DeviceInfo

enum DeviceInfo {
    /// Returns the device model identifier (e.g., "iPhone15,2")
    static var deviceModelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    /// Returns the device model name (e.g., "iPhone 14 Pro")
    static var deviceModel: String {
        let identifier = deviceModelIdentifier
        return deviceNameMapping[identifier] ?? identifier
    }

    /// Returns the iOS version string
    static var systemVersion: String {
        UIDevice.current.systemVersion
    }

    /// Returns the app's version string from the bundle
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    /// Returns the app's build number from the bundle
    static var appBuildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    /// Returns the full app version (version + build)
    static var appVersionFull: String {
        "\(appVersion) (\(appBuildNumber))"
    }

    /// Returns whether the app is running in the simulator
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// Returns whether the device has a notch (iPhone X and later)
    static var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        let window = windowScene.windows.first
        let safeAreaInsets = window?.safeAreaInsets ?? .zero
        return safeAreaInsets.top > 20
    }

    /// Returns whether the device is a Mac
    static var isMac: Bool {
        UIDevice.current.userInterfaceIdiom == .mac
    }

    /// Returns whether the device is an iPad
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Returns whether the device is an iPhone
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    /// Returns the screen size in points
    static var screenSize: CGSize {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        return windowScene.screen.bounds.size
    }

    /// Returns the screen scale factor
    static var screenScale: CGFloat {
        UIScreen.main.scale
    }

    /// Returns the screen size in pixels
    static var screenSizeInPixels: CGSize {
        CGSize(
            width: screenSize.width * screenScale,
            height: screenSize.height * screenScale
        )
    }

    /// Returns the device name
    static var deviceName: String {
        UIDevice.current.name
    }

    /// Returns the system name (e.g., "iOS")
    static var systemName: String {
        UIDevice.current.systemName
    }

    /// Device name mapping from identifier to human-readable name
    private static let deviceNameMapping: [String: String] = [
        // iPhone
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        // iPad
        "iPad13,1": "iPad Air (4th generation)",
        "iPad13,2": "iPad Air (4th generation)",
        "iPad13,4": "iPad Pro 11-inch (3rd generation)",
        "iPad13,5": "iPad Pro 11-inch (3rd generation)",
        "iPad13,6": "iPad Pro 12.9-inch (5th generation)",
        "iPad13,7": "iPad Pro 12.9-inch (5th generation)",
        // Apple Watch
        "Watch6,1": "Apple Watch SE",
        "Watch6,2": "Apple Watch Series 6",
        "Watch7,1": "Apple Watch Series 7",
        "Watch7,2": "Apple Watch Series 7",
        "Watch7,3": "Apple Watch Series 7",
        "Watch7,4": "Apple Watch Series 8",
        "Watch7,5": "Apple Watch Series 8",
        "Watch7,6": "Apple Watch Series 8",
        // Mac
        "Mac14,2": "MacBook Air (M2)",
        "Mac14,7": "MacBook Pro (13-inch, M2)",
        "Mac15,12": "MacBook Pro 14-inch (M3 Pro)",
        "Mac15,9": "MacBook Pro 14-inch (M3)",
    ]
}
