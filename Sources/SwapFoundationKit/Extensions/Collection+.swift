/*****************************************************************************
 * Collection+.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Returns true if the collection is not empty.
    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - Collection+Chunked

public extension Collection {
    /// Splits the collection into chunks of the specified size
    /// - Parameter size: The size of each chunk
    /// - Returns: An array of chunks
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        var chunks: [[Element]] = []
        var currentChunk: [Element] = []

        for element in self {
            currentChunk.append(element)
            if currentChunk.count == size {
                chunks.append(currentChunk)
                currentChunk = []
            }
        }

        // Add remaining elements if any
        if currentChunk.isNotEmpty {
            chunks.append(currentChunk)
        }

        return chunks
    }

    /// Groups elements into groups of the specified size
    /// Similar to chunked but pads the last group if necessary
    /// - Parameter size: The size of each group
    /// - Returns: An array of groups
    func grouped(by size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        var groups: [[Element]] = []
        var currentGroup: [Element] = []

        for element in self {
            currentGroup.append(element)
            if currentGroup.count == size {
                groups.append(currentGroup)
                currentGroup = []
            }
        }

        // Pad the last group with nil if needed (represented as optionals)
        if currentGroup.isNotEmpty {
            groups.append(currentGroup)
        }

        return groups
    }

    /// Returns the first element matching the predicate
    /// - Parameter predicate: The predicate to match
    /// - Returns: The first matching element or nil
    func first(where predicate: (Element) -> Bool) -> Element? {
        for element in self {
            if predicate(element) {
                return element
            }
        }
        return nil
    }

    /// Returns all elements matching the predicate
    /// - Parameter predicate: The predicate to match
    /// - Returns: All matching elements
    func filter(_ predicate: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for element in self {
            if predicate(element) {
                result.append(element)
            }
        }
        return result
    }
}