import Foundation
import CoreGraphics

struct Image {
    var pixels: [(UInt8, UInt8, UInt8)]

    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.pixels = [(UInt8, UInt8, UInt8)](repeating: (0, 0, 0), count: width * height)
    }

    subscript(i: Int) -> (UInt8, UInt8, UInt8) {
        get {
            pixels[i]
        }

        mutating set {
            pixels[i] = newValue
        }
    }

    subscript(x: Int, y: Int) -> (UInt8, UInt8, UInt8) {
        get {
            pixels[(y * width) + x]
        }

        mutating set {
            pixels[(y * width) + x] = newValue
        }
    }

    func makeCGImage() -> CGImage? {
        var pix = self.pixels
        let sz = MemoryLayout<(UInt8, UInt8, UInt8)>.size
        let data = Data(bytesNoCopy: &pix, count: pix.count * sz, deallocator: .none)
        guard let dp = CGDataProvider(data: data as CFData) else {
            return nil
        }

        let bmi: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)]

        return CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 24,
                bytesPerRow: width * sz,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: bmi,
                provider: dp,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent)
    }

    func writePNG(to url: URL) {
        guard
                let img = makeCGImage(),
                let dest = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)
                else {
            return
        }

        CGImageDestinationAddImage(dest, img, nil)
        CGImageDestinationFinalize(dest)
    }
}