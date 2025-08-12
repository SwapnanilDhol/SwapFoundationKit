# Image Processor

The SwapFoundationKit provides a powerful `ImageProcessor` service for image manipulation, processing, caching, and file operations. Built with performance and ease of use in mind, it offers a comprehensive suite of image processing capabilities.

## 🖼️ Features

- **🔄 Image Processing** - Resize, round corners, grayscale conversion, blur effects
- **💾 Intelligent Caching** - Memory-based caching with configurable limits
- **📁 File Operations** - Save/load images to/from documents directory
- **⚡ Performance Optimized** - Efficient Core Graphics and Core Image operations
- **🛡️ Error Handling** - Comprehensive error handling with localized descriptions
- **🎯 Singleton Pattern** - Easy access throughout your app

## 🚀 Quick Start

### 1. Basic Image Processing

```swift
import SwapFoundationKit

// Get the shared instance
let imageProcessor = ImageProcessor.shared

// Resize an image
if let resizedImage = imageProcessor.resize(originalImage, to: CGSize(width: 300, height: 300)) {
    // Use the resized image
    imageView.image = resizedImage
}

// Round corners
if let roundedImage = imageProcessor.roundCorners(originalImage, radius: 20) {
    // Use the rounded image
    imageView.image = roundedImage
}
```

### 2. Image Caching

```swift
import SwapFoundationKit

let imageProcessor = ImageProcessor.shared

// Cache an image
imageProcessor.cacheImage(profileImage, forKey: "user_profile_123")

// Retrieve cached image
if let cachedImage = imageProcessor.cachedImage(forKey: "user_profile_123") {
    imageView.image = cachedImage
} else {
    // Load from network and cache
    loadAndCacheProfileImage()
}
```

### 3. File Operations

```swift
import SwapFoundationKit

let imageProcessor = ImageProcessor.shared

do {
    // Save image to documents directory
    let savedURL = try imageProcessor.saveImage(profileImage, filename: "profile.jpg", quality: 0.9)
    print("Image saved to: \(savedURL)")
    
    // Load image from documents directory
    let loadedImage = try imageProcessor.loadImage(filename: "profile.jpg")
    imageView.image = loadedImage
    
} catch ImageProcessorError.documentsDirectoryNotFound {
    print("Documents directory not found")
} catch ImageProcessorError.compressionFailed {
    print("Failed to compress image")
} catch ImageProcessorError.loadFailed {
    print("Failed to load image")
} catch {
    print("Unexpected error: \(error)")
}
```

## 📱 Complete Usage Example

```swift
import SwapFoundationKit
import UIKit

class ProfileImageManager: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var isLoading = false
    
    private let imageProcessor = ImageProcessor.shared
    private let cacheKey = "user_profile_image"
    
    func loadProfileImage() {
        // First, try to load from cache
        if let cachedImage = imageProcessor.cachedImage(forKey: cacheKey) {
            profileImage = cachedImage
            return
        }
        
        // Then, try to load from documents directory
        do {
            let loadedImage = try imageProcessor.loadImage(filename: "profile.jpg")
            profileImage = loadedImage
            // Cache the loaded image
            imageProcessor.cacheImage(loadedImage, forKey: cacheKey)
        } catch {
            // Load from network (implement your network loading logic)
            loadProfileImageFromNetwork()
        }
    }
    
    func saveProfileImage(_ image: UIImage) {
        do {
            // Save to documents directory
            let savedURL = try imageProcessor.saveImage(image, filename: "profile.jpg", quality: 0.9)
            print("Profile image saved to: \(savedURL)")
            
            // Cache the image
            imageProcessor.cacheImage(image, forKey: cacheKey)
            
            // Update the published property
            profileImage = image
            
        } catch {
            print("Failed to save profile image: \(error)")
        }
    }
    
    func processAndSaveProfileImage(_ image: UIImage) {
        isLoading = true
        
        // Process the image
        guard let processedImage = processImage(image) else {
            isLoading = false
            return
        }
        
        // Save the processed image
        saveProfileImage(processedImage)
        isLoading = false
    }
    
    private func processImage(_ image: UIImage) -> UIImage? {
        // Resize to standard profile size
        guard let resizedImage = imageProcessor.resize(image, to: CGSize(width: 200, height: 200)) else {
            return nil
        }
        
        // Round corners for profile picture style
        guard let roundedImage = imageProcessor.roundCorners(resizedImage, radius: 100) else {
            return nil
        }
        
        return roundedImage
    }
    
    private func loadProfileImageFromNetwork() {
        // Implement your network loading logic here
        // After loading, call saveProfileImage(_:)
    }
}

struct ProfileImageView: View {
    @StateObject private var imageManager = ProfileImageManager()
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let profileImage = imageManager.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            if imageManager.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            
            Button("Change Profile Picture") {
                showingImagePicker = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(imageManager.isLoading)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear {
            imageManager.loadProfileImage()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                if let image = image {
                    imageManager.processAndSaveProfileImage(image)
                }
            }
        }
    }
}

// Image picker for selecting new profile images
struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.onImageSelected(image)
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageSelected(nil)
            picker.dismiss(animated: true)
        }
    }
}
```

## 🔧 Advanced Usage

### Batch Image Processing

```swift
import SwapFoundationKit

class BatchImageProcessor {
    private let imageProcessor = ImageProcessor.shared
    
    func processImages(_ images: [UIImage], size: CGSize, cornerRadius: CGFloat) async -> [UIImage] {
        return await withTaskGroup(of: UIImage?.self) { group in
            var processedImages: [UIImage] = []
            
            for image in images {
                group.addTask {
                    // Resize image
                    guard let resized = self.imageProcessor.resize(image, to: size) else {
                        return nil
                    }
                    
                    // Round corners
                    guard let rounded = self.imageProcessor.roundCorners(resized, radius: cornerRadius) else {
                        return nil
                    }
                    
                    return rounded
                }
            }
            
            for await processedImage in group {
                if let image = processedImage {
                    processedImages.append(image)
                }
            }
            
            return processedImages
        }
    }
    
    func applyFiltersToImages(_ images: [UIImage], filter: ImageFilter) async -> [UIImage] {
        return await withTaskGroup(of: UIImage?.self) { group in
            var filteredImages: [UIImage] = []
            
            for image in images {
                group.addTask {
                    switch filter {
                    case .grayscale:
                        return self.imageProcessor.toGrayscale(image)
                    case .blur:
                        return self.imageProcessor.applyBlur(image)
                    case .none:
                        return image
                    }
                }
            }
            
            for await filteredImage in group {
                if let image = filteredImage {
                    filteredImages.append(image)
                }
            }
            
            return filteredImages
        }
    }
}

enum ImageFilter {
    case grayscale
    case blur
    case none
}

// Usage
let batchProcessor = BatchImageProcessor()

Task {
    let processedImages = await batchProcessor.processImages(
        imageArray,
        size: CGSize(width: 300, height: 300),
        cornerRadius: 15
    )
    
    let grayscaleImages = await batchProcessor.applyFiltersToImages(processedImages, filter: .grayscale)
    
    // Use the processed images
    DispatchQueue.main.async {
        // Update UI with processed images
    }
}
```

### Custom Image Processing Pipeline

```swift
import SwapFoundationKit

class ImageProcessingPipeline {
    private let imageProcessor = ImageProcessor.shared
    
    struct ProcessingStep {
        let name: String
        let processor: (UIImage) -> UIImage?
    }
    
    private var steps: [ProcessingStep] = []
    
    func addStep(_ step: ProcessingStep) {
        steps.append(step)
    }
    
    func processImage(_ image: UIImage) -> UIImage? {
        var currentImage = image
        
        for step in steps {
            guard let processedImage = step.processor(currentImage) else {
                print("Failed at step: \(step.name)")
                return nil
            }
            currentImage = processedImage
        }
        
        return currentImage
    }
}

// Usage
let pipeline = ImageProcessingPipeline()

// Add processing steps
pipeline.addStep(ProcessingStep(name: "Resize") { image in
    return ImageProcessor.shared.resize(image, to: CGSize(width: 400, height: 400))
})

pipeline.addStep(ProcessingStep(name: "Round Corners") { image in
    return ImageProcessor.shared.roundCorners(image, radius: 25)
})

pipeline.addStep(ProcessingStep(name: "Apply Blur") { image in
    return ImageProcessor.shared.applyBlur(image, style: .light)
})

// Process image through pipeline
if let processedImage = pipeline.processImage(originalImage) {
    imageView.image = processedImage
}
```

### Advanced Caching Strategies

```swift
import SwapFoundationKit

class AdvancedImageCache {
    private let imageProcessor = ImageProcessor.shared
    private let cache = NSCache<NSString, CachedImageInfo>()
    
    struct CachedImageInfo {
        let image: UIImage
        let timestamp: Date
        let accessCount: Int
        let size: Int
    }
    
    func cacheImage(_ image: UIImage, forKey key: String, metadata: [String: Any] = [:]) {
        let imageData = image.jpegData(compressionQuality: 1.0)
        let size = imageData?.count ?? 0
        
        let cachedInfo = CachedImageInfo(
            image: image,
            timestamp: Date(),
            accessCount: 1,
            size: size
        )
        
        cache.setObject(cachedInfo, forKey: key as NSString)
        
        // Also save to documents directory for persistence
        do {
            try imageProcessor.saveImage(image, filename: "\(key).jpg", quality: 0.8)
        } catch {
            print("Failed to persist image: \(error)")
        }
    }
    
    func getCachedImage(forKey key: String) -> UIImage? {
        guard let cachedInfo = cache.object(forKey: key as NSString) else {
            // Try to load from documents directory
            do {
                let image = try imageProcessor.loadImage(filename: "\(key).jpg")
                // Update cache with new access info
                let updatedInfo = CachedImageInfo(
                    image: image,
                    timestamp: cachedInfo?.timestamp ?? Date(),
                    accessCount: (cachedInfo?.accessCount ?? 0) + 1,
                    size: cachedInfo?.size ?? 0
                )
                cache.setObject(updatedInfo, forKey: key as NSString)
                return image
            } catch {
                return nil
            }
        }
        
        // Update access count
        let updatedInfo = CachedImageInfo(
            image: cachedInfo.image,
            timestamp: cachedInfo.timestamp,
            accessCount: cachedInfo.accessCount + 1,
            size: cachedInfo.size
        )
        cache.setObject(updatedInfo, forKey: key as NSString)
        
        return cachedInfo.image
    }
    
    func getCacheStatistics() -> [String: Any] {
        var totalSize = 0
        var totalImages = 0
        var oldestImage: Date?
        var mostAccessedImage: String?
        var maxAccessCount = 0
        
        for (key, info) in cache.objectEnumerator() {
            if let key = key as? String, let info = info as? CachedImageInfo {
                totalSize += info.size
                totalImages += 1
                
                if oldestImage == nil || info.timestamp < oldestImage! {
                    oldestImage = info.timestamp
                }
                
                if info.accessCount > maxAccessCount {
                    maxAccessCount = info.accessCount
                    mostAccessedImage = key
                }
            }
        }
        
        return [
            "totalImages": totalImages,
            "totalSizeBytes": totalSize,
            "totalSizeMB": Double(totalSize) / (1024 * 1024),
            "oldestImage": oldestImage?.timeIntervalSince1970 ?? 0,
            "mostAccessedImage": mostAccessedImage ?? "None",
            "maxAccessCount": maxAccessCount
        ]
    }
}
```

## 🏗️ Architecture

### Singleton Pattern

The `ImageProcessor` uses a singleton pattern for easy access throughout your app:

```swift
public static let shared = ImageProcessor()
```

### Memory Management

- **Cache Limits**: 100 images maximum, 50MB total memory
- **Automatic Cleanup**: NSCache automatically removes objects when memory pressure is high
- **Efficient Operations**: Uses Core Graphics and Core Image for optimal performance

### Error Handling

Comprehensive error handling with `ImageProcessorError`:

```swift
public enum ImageProcessorError: Error, LocalizedError {
    case documentsDirectoryNotFound
    case compressionFailed
    case loadFailed
}
```

## 🧪 Testing

### Mock Image Processor

```swift
class MockImageProcessor: ImageProcessor {
    var mockResizedImages: [CGSize: UIImage] = [:]
    var mockRoundedImages: [CGFloat: UIImage] = [:]
    var mockGrayscaleImages: [UIImage: UIImage] = [:]
    var mockBlurredImages: [UIImage: UIImage] = [:]
    
    override func resize(_ image: UIImage, to size: CGSize, quality: CGFloat = 1.0) -> UIImage? {
        return mockResizedImages[size] ?? image
    }
    
    override func roundCorners(_ image: UIImage, radius: CGFloat) -> UIImage? {
        return mockRoundedImages[radius] ?? image
    }
    
    override func toGrayscale(_ image: UIImage) -> UIImage? {
        return mockGrayscaleImages[image] ?? image
    }
    
    override func applyBlur(_ image: UIImage, style: UIBlurEffect.Style = .light) -> UIImage? {
        return mockBlurredImages[image] ?? image
    }
    
    func setMockResizedImage(_ image: UIImage, for size: CGSize) {
        mockResizedImages[size] = image
    }
    
    func setMockRoundedImage(_ image: UIImage, for radius: CGFloat) {
        mockRoundedImages[radius] = image
    }
}

// In your tests
class ImageProcessorTests: XCTestCase {
    var mockProcessor: MockImageProcessor!
    
    override func setUp() {
        super.setUp()
        mockProcessor = MockImageProcessor()
    }
    
    func testImageResize() {
        // Given
        let testImage = UIImage()
        let targetSize = CGSize(width: 200, height: 200)
        let expectedImage = UIImage()
        mockProcessor.setMockResizedImage(expectedImage, for: targetSize)
        
        // When
        let result = mockProcessor.resize(testImage, to: targetSize)
        
        // Then
        XCTAssertEqual(result, expectedImage)
    }
}
```

## 📱 SwiftUI Integration

### Image Processing View Modifier

```swift
import SwiftUI
import SwapFoundationKit

struct ProcessedImage: View {
    let image: UIImage
    let processor: ImageProcessor
    @State private var processedImage: UIImage?
    @State private var isProcessing = false
    
    var body: some View {
        Group {
            if let processedImage = processedImage {
                Image(uiImage: processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .onAppear {
            processImage()
        }
        .overlay(
            Group {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                }
            }
        )
    }
    
    private func processImage() {
        isProcessing = true
        
        Task {
            // Process image on background thread
            let resized = processor.resize(image, to: CGSize(width: 300, height: 300))
            let rounded = resized.flatMap { processor.roundCorners($0, radius: 20) }
            
            await MainActor.run {
                processedImage = rounded
                isProcessing = false
            }
        }
    }
}

// Usage
ProcessedImage(
    image: originalImage,
    processor: ImageProcessor.shared
)
```

## 🔧 Configuration

### Custom Cache Settings

```swift
extension ImageProcessor {
    func configureCache(maxCount: Int, maxMemory: Int) {
        cache.countLimit = maxCount
        cache.totalCostLimit = maxMemory
    }
    
    func getCacheInfo() -> (count: Int, memory: Int) {
        return (cache.totalCostLimit, cache.countLimit)
    }
}

// Usage
let processor = ImageProcessor.shared
processor.configureCache(maxCount: 200, maxMemory: 100 * 1024 * 1024) // 100MB
```

### Custom Processing Options

```swift
extension ImageProcessor {
    func resizeWithAspectRatio(_ image: UIImage, targetSize: CGSize, maintainAspectRatio: Bool = true) -> UIImage? {
        if maintainAspectRatio {
            let aspectRatio = image.size.width / image.size.height
            let targetAspectRatio = targetSize.width / targetSize.height
            
            var finalSize = targetSize
            if aspectRatio > targetAspectRatio {
                finalSize.height = targetSize.width / aspectRatio
            } else {
                finalSize.width = targetSize.height * aspectRatio
            }
            
            return resize(image, to: finalSize)
        } else {
            return resize(image, to: targetSize)
        }
    }
    
    func applyCustomBlur(_ image: UIImage, intensity: Float) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(intensity, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
```

## 📈 Performance Considerations

### Memory Management

- **Efficient Caching**: NSCache automatically handles memory pressure
- **Image Compression**: Configurable JPEG quality for file operations
- **Background Processing**: Process images on background threads

### Optimization Tips

1. **Batch Processing**: Use `BatchImageProcessor` for multiple images
2. **Cache Strategy**: Implement custom caching based on your app's needs
3. **Image Sizes**: Resize images before processing to reduce memory usage
4. **Quality Settings**: Use appropriate compression quality for your use case

## 🚨 Error Handling

### Comprehensive Error Handling

```swift
func handleImageProcessing(_ image: UIImage) {
    do {
        // Process and save image
        let processedImage = imageProcessor.resize(image, to: CGSize(width: 300, height: 300))
        let savedURL = try imageProcessor.saveImage(processedImage!, filename: "processed.jpg")
        
        print("Image processed and saved successfully: \(savedURL)")
        
    } catch ImageProcessorError.documentsDirectoryNotFound {
        print("❌ Documents directory not accessible")
        // Handle directory access issues
        
    } catch ImageProcessorError.compressionFailed {
        print("❌ Failed to compress image")
        // Handle compression failures
        
    } catch ImageProcessorError.loadFailed {
        print("❌ Failed to load image")
        // Handle loading failures
        
    } catch {
        print("❌ Unexpected error: \(error)")
        // Handle unexpected errors
    }
}
```

This ImageProcessor provides a robust, performant foundation for image manipulation in your iOS, macOS, and watchOS applications with comprehensive caching, file operations, and image processing capabilities.
