import SwiftUI
import PhotosUI

@MainActor
class MediaManager: ObservableObject {
    static let shared = MediaManager()
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: UIImage, fileName: String = UUID().uuidString + ".jpg") -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func deleteImage(fileName: String) {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
