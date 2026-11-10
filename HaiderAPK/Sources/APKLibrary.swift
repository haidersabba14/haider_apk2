import Foundation
import Combine

struct APKRecord: Identifiable, Codable {
    let id: UUID
    let name: String
    let savedFileName: String
    let sizeBytes: Int64
    let importedAt: Date
    let entryCount: Int
    let nativeABIs: [String]
    let filePreview: [String]

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}

@MainActor
final class APKLibrary: ObservableObject {
    @Published private(set) var packages: [APKRecord] = []

    private let fileManager = FileManager.default

    private var libraryDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("APKLibrary", isDirectory: true)
    }

    private var indexFile: URL {
        libraryDirectory.appendingPathComponent("index.json")
    }

    init() {
        try? fileManager.createDirectory(
            at: libraryDirectory,
            withIntermediateDirectories: true
        )
        if let data = try? Data(contentsOf: indexFile),
           let saved = try? JSONDecoder().decode([APKRecord].self, from: data) {
            packages = saved.filter {
                fileManager.fileExists(atPath: url(for: $0).path)
            }
        }
    }

    func url(for record: APKRecord) -> URL {
        libraryDirectory.appendingPathComponent(record.savedFileName)
    }

    func importFiles(_ sources: [URL]) throws {
        for source in sources {
            try importOne(source)
        }
    }

    private func importOne(_ source: URL) throws {
        guard source.pathExtension.lowercased() == "apk" else {
            throw ImportFailure.incorrectExtension
        }

        let canAccess = source.startAccessingSecurityScopedResource()
        defer {
            if canAccess { source.stopAccessingSecurityScopedResource() }
        }

        let uniqueFileName = UUID().uuidString + ".apk"
        let destination = libraryDirectory.appendingPathComponent(uniqueFileName)
        try fileManager.copyItem(at: source, to: destination)

        do {
            let analysis = try APKInspector.inspect(destination)
            let attributes = try fileManager.attributesOfItem(atPath: destination.path)
            let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0

            let record = APKRecord(
                id: UUID(),
                name: source.deletingPathExtension().lastPathComponent,
                savedFileName: uniqueFileName,
                sizeBytes: size,
                importedAt: Date(),
                entryCount: analysis.entryCount,
                nativeABIs: analysis.nativeABIs,
                filePreview: analysis.filePreview
            )
            packages.insert(record, at: 0)
            saveIndex()
        } catch {
            try? fileManager.removeItem(at: destination)
            throw error
        }
    }

    func delete(_ package: APKRecord) {
        try? fileManager.removeItem(at: url(for: package))
        packages.removeAll { $0.id == package.id }
        saveIndex()
    }

    private func saveIndex() {
        guard let data = try? JSONEncoder().encode(packages) else { return }
        try? data.write(to: indexFile, options: .atomic)
    }
}

enum ImportFailure: LocalizedError {
    case incorrectExtension

    var errorDescription: String? {
        "اختر ملفًا بامتداد APK فقط."
    }
}
