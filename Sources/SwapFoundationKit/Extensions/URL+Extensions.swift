import Foundation

// MARK: - URL+Extensions

extension URL {
    /// Returns the query parameters as a dictionary
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }

        var params: [String: String] = [:]
        for item in queryItems {
            if let value = item.value {
                params[item.name] = value
            }
        }
        return params.isEmpty ? nil : params
    }

    /// Returns the URL scheme
    var scheme: String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.scheme
    }

    /// Returns the URL host
    var host: String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.host
    }

    /// Returns whether the URL uses HTTPS
    var isHTTPS: Bool {
        scheme?.lowercased() == "https"
    }

    /// Returns whether the URL uses HTTP
    var isHTTP: Bool {
        scheme?.lowercased() == "http"
    }

    /// Appends a query item to the URL
    /// - Parameters:
    ///   - name: The name of the query parameter
    ///   - value: The value of the query parameter
    /// - Returns: A new URL with the query parameter appended
    func appendingQueryItem(name: String, value: String?) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }

        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: name, value: value))
        components.queryItems = queryItems

        return components.url ?? self
    }

    /// Removes all query parameters from the URL
    /// - Returns: A new URL without query parameters
    func removingQueryParameters() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        components.queryItems = nil
        return components.url ?? self
    }

    /// Checks if a string is a valid URL
    /// - Parameter string: The string to validate
    /// - Returns: True if the string is a valid URL
    static func isValid(_ string: String) -> Bool {
        guard let url = URL(string: string) else {
            return false
        }
        return url.scheme != nil && url.host != nil
    }

    /// Returns the file extension without the dot
    var fileExtension: String {
        pathExtension
    }

    /// Returns the last path component without the extension
    var fileName: String {
        deletingPathExtension().lastPathComponent
    }
}
