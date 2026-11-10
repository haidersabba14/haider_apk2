import AppKit
import Foundation

// Generates a simple Haider-branded 1024px icon before the Xcode build.
let pixels = 1024
let side = CGFloat(pixels)
let output = URL(fileURLWithPath: "HaiderAPK/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)

guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixels,
    pixelsHigh: pixels,
    bitsPerSample: 8,
    samplesPerPixel: 3,
    hasAlpha: false,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Could not create image buffer")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
let canvas = NSRect(x: 0, y: 0, width: side, height: side)
NSColor(calibratedRed: 0.035, green: 0.040, blue: 0.09, alpha: 1).setFill()
NSBezierPath(rect: canvas).fill()

let tile = NSBezierPath(roundedRect: canvas.insetBy(dx: 56, dy: 56), xRadius: 218, yRadius: 218)
NSGradient(colors: [
    NSColor(calibratedRed: 0.10, green: 0.45, blue: 0.95, alpha: 1),
    NSColor(calibratedRed: 0.52, green: 0.18, blue: 0.83, alpha: 1)
])!.draw(in: tile, angle: -34)

let inner = NSBezierPath(roundedRect: canvas.insetBy(dx: 90, dy: 90), xRadius: 189, yRadius: 189)
NSColor(calibratedRed: 0.045, green: 0.05, blue: 0.13, alpha: 1).setFill()
inner.fill()

let h = NSAttributedString(string: "H", attributes: [
    .font: NSFont.systemFont(ofSize: 615, weight: .black),
    .foregroundColor: NSColor.white
])
let hSize = h.size()
h.draw(at: NSPoint(x: (side - hSize.width) / 2, y: (side - hSize.height) / 2 + 70))

let apk = NSAttributedString(string: "APK", attributes: [
    .font: NSFont.systemFont(ofSize: 125, weight: .heavy),
    .foregroundColor: NSColor(calibratedRed: 0.36, green: 0.84, blue: 1, alpha: 1)
])
let aSize = apk.size()
apk.draw(at: NSPoint(x: (side - aSize.width) / 2, y: 177))

context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode app icon")
}
try png.write(to: output)
print("Generated \(output.path)")
