# ImageProcessor

Image manipulation, caching, and compression utilities.

## Public API

| Type | Kind | Description |
|------|------|-------------|
| `ImageProcessor` | class | Resize, round corners, grayscale, blur, caching |
| `SFKImageCompressor` | enum | JPEG compression with configurable max dimension and quality |

### ImageProcessor
| Method | Description |
|--------|-------------|
| `.shared.resize(_:to:quality:)` | Resize to target size |
| `.shared.roundCorners(_:radius:)` | Rounded corners |
| `.shared.toGrayscale(_:)` | Grayscale conversion |
| `.shared.applyBlur(_:style:)` | Gaussian blur via Core Image |
| `.shared.cacheImage(_:forKey:)` | In-memory cache (50MB, 100 items) |
| `.shared.cachedImage(forKey:)` | Retrieve from memory cache |
| `.shared.cacheImage(from:targetSize:quality:)` | Download, resize, cache in memory + shared storage |
| `.shared.cachedImage(from:targetSize:)` | Look up cached remote image |
| `.shared.configure(shouldCacheToSharedStorage:appGroupIdentifier:)` | Enable widget/extension caching |
| `.shared.saveImage(_:filename:quality:)` / `.shared.loadImage(filename:)` | File I/O |

### SFKImageCompressor
| Property/Method | Description |
|-----------------|-------------|
| `.maxDimension` | Max width/height (default: 256) |
| `.compressionQuality` | JPEG quality (default: 0.7) |
| `.compress(_:)` | Resize + JPEG compress |
| `.compressToSize(_:maxBytes:)` | Compress to target file size |

```swift
// Process
let resized = ImageProcessor.shared.resize(image, to: CGSize(width: 100, height: 100))
let blurred = ImageProcessor.shared.applyBlur(image, style: .light)

// Cache
ImageProcessor.shared.cacheImage(avatar, forKey: "user-avatar")
let cached = ImageProcessor.shared.cachedImage(forKey: "user-avatar")

// Compress
guard let jpeg = SFKImageCompressor.compress(largeImage) else { return }
```

## Source Files

- `ImageProcessor.swift` — Full image processing and caching
- `SFKImageCompressor.swift` — JPEG compression utility
