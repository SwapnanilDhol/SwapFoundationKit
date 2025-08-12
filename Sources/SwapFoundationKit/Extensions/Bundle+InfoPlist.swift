import Foundation

public extension Bundle {
    enum InfoPlistKey: Equatable {
        case appName
        case displayName
        case executable
        case developmentRegion
        case minimumOSVersion
        case deviceFamily
        case requiredDeviceCapabilities
        case urlTypes
        case appTransportSecurity
        case shortVersion
        case buildVersion
        case bundleIdentifier
        case appIconName
        case copyright
        case custom(String)

        public var rawValue: String {
            switch self {
            case .appName: return "CFBundleName"
            case .displayName: return "CFBundleDisplayName"
            case .executable: return "CFBundleExecutable"
            case .developmentRegion: return "CFBundleDevelopmentRegion"
            case .minimumOSVersion: return "MinimumOSVersion"
            case .deviceFamily: return "UIDeviceFamily"
            case .requiredDeviceCapabilities: return "UIRequiredDeviceCapabilities"
            case .urlTypes: return "CFBundleURLTypes"
            case .appTransportSecurity: return "NSAppTransportSecurity"
            case .shortVersion: return "CFBundleShortVersionString"
            case .buildVersion: return "CFBundleVersion"
            case .bundleIdentifier: return "CFBundleIdentifier"
            case .appIconName: return "CFBundleIcons"
            case .copyright: return "NSHumanReadableCopyright"
            case .custom(let key): return key
            }
        }
    }

    /// Returns the value for a given Info.plist key as the specified type, or a default value if not found or type mismatch.
    func infoPlistValue<T>(forKey key: String, default defaultValue: T) -> T {
        guard let value = infoDictionary?[key] else { return defaultValue }
        // Try to cast directly
        if let typedValue = value as? T {
            return typedValue
        }
        // Try to convert from String for primitive types
        if let stringValue = value as? String {
            switch T.self {
            case is Int.Type:
                return (Int(stringValue) as? T) ?? defaultValue
            case is Double.Type:
                return (Double(stringValue) as? T) ?? defaultValue
            case is Float.Type:
                return (Float(stringValue) as? T) ?? defaultValue
            case is Bool.Type:
                return (Bool(stringValue) as? T) ?? defaultValue
            case is String.Type:
                return (stringValue as? T) ?? defaultValue
            default:
                return defaultValue
            }
        }
        return defaultValue
    }

    /// Overload: Returns the value for a given InfoPlistKey as the specified type, or a default value if not found or type mismatch.
    func infoPlistValue<T>(forKey key: InfoPlistKey, default defaultValue: T) -> T {
        return infoPlistValue(forKey: key.rawValue, default: defaultValue)
    }

    // MARK: - Common Info.plist Properties

    var appName: String {
        infoPlistValue(forKey: .appName, default: "")
    }
    var displayName: String {
        infoPlistValue(forKey: .displayName, default: appName)
    }
    var executable: String {
        infoPlistValue(forKey: .executable, default: "")
    }
    var developmentRegion: String {
        infoPlistValue(forKey: .developmentRegion, default: "")
    }
    var minimumOSVersion: String {
        infoPlistValue(forKey: .minimumOSVersion, default: "")
    }
    var deviceFamily: [Int] {
        infoPlistValue(forKey: .deviceFamily, default: [])
    }
    var requiredDeviceCapabilities: [String] {
        infoPlistValue(forKey: .requiredDeviceCapabilities, default: [])
    }
    var urlTypes: [[String: Any]] {
        infoPlistValue(forKey: .urlTypes, default: [])
    }
    var appTransportSecurity: [String: Any] {
        infoPlistValue(forKey: .appTransportSecurity, default: [:])
    }
    var releaseVersionNumber: String {
        infoPlistValue(forKey: .shortVersion, default: "")
    }
    var buildVersionNumber: String {
        infoPlistValue(forKey: .buildVersion, default: "")
    }
    var bundleIdentifier: String {
        infoPlistValue(forKey: .bundleIdentifier, default: "")
    }
    var copyright: String {
        infoPlistValue(forKey: .copyright, default: "")
    }

    // MARK: - App Icon Name
    var appIconName: String? {
        // iOS: CFBundleIcons > CFBundlePrimaryIcon > CFBundleIconFiles
        guard let icons = infoDictionary?[InfoPlistKey.appIconName.rawValue] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconName = iconFiles.last else {
            return nil
        }
        return iconName
    }

    // MARK: - URL Schemes
    var urlSchemes: [String] {
        guard let urlTypes = infoDictionary?[InfoPlistKey.urlTypes.rawValue] as? [[String: Any]] else { return [] }
        return urlTypes.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 }
    }

    // MARK: - Build Configuration
    #if DEBUG
    var isDebugBuild: Bool { true }
    #else
    var isDebugBuild: Bool { false }
    #endif

    // MARK: - Localized InfoPlist
    func localizedInfoPlistValue(forKey key: String, table: String = "InfoPlist") -> String? {
        return localizedString(forKey: key, value: nil, table: table)
    }

    // MARK: - Generic Plist File Access
    func plistValue<T>(named plistName: String, key: String, default defaultValue: T) -> T {
        guard let url = url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let value = plist[key] else {
            return defaultValue
        }
        if let typedValue = value as? T {
            return typedValue
        }
        if let stringValue = value as? String {
            switch T.self {
            case is Int.Type:
                return (Int(stringValue) as? T) ?? defaultValue
            case is Double.Type:
                return (Double(stringValue) as? T) ?? defaultValue
            case is Float.Type:
                return (Float(stringValue) as? T) ?? defaultValue
            case is Bool.Type:
                return (Bool(stringValue) as? T) ?? defaultValue
            case is String.Type:
                return (stringValue as? T) ?? defaultValue
            default:
                return defaultValue
            }
        }
        return defaultValue
    }
} 
