import Foundation
import ZIPFoundation

struct APKAnalysis {
    let entryCount: Int
    let hasManifest: Bool
    let hasDex: Bool
    let nativeABIs: [String]
    let filePreview: [String]
}

enum APKInspectError: LocalizedError {
    case notAnAPK

    var errorDescription: String? {
        switch self {
        case .notAnAPK:
            return "الملف ليس APK صالحًا: يجب أن يحتوي على AndroidManifest.xml وملف DEX."
        }
    }
}

enum APKInspector {
    static func inspect(_ url: URL) throws -> APKAnalysis {
        // An APK is a ZIP archive. Inspection is local and does not execute app code.
        let archive = try Archive(url: url, accessMode: .read)
        var count = 0
        var manifest = false
        var dex = false
        var abis = Set<String>()
        var preview: [String] = []

        for entry in archive {
            let path = entry.path
            count += 1
            if count <= 35 { preview.append(path) }
            if path == "AndroidManifest.xml" { manifest = true }
            if path == "classes.dex" ||
                (path.hasPrefix("classes") && path.hasSuffix(".dex")) {
                dex = true
            }
            let components = path.split(separator: "/")
            if components.count >= 3 &&
                components[0] == "lib" &&
                components[2].hasSuffix(".so") {
                abis.insert(String(components[1]))
            }
        }

        guard manifest && dex else { throw APKInspectError.notAnAPK }
        return APKAnalysis(
            entryCount: count,
            hasManifest: manifest,
            hasDex: dex,
            nativeABIs: abis.sorted(),
            filePreview: preview
        )
    }
}
