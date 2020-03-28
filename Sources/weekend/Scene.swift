//
// Created by Stuart Carnie on 3/27/20.
//

import Foundation

@usableFromInline
@frozen
struct Scene {
    @usableFromInline
    let camera: Camera

    @usableFromInline
    let world: World

    @usableFromInline
    let maxDepth: Int

    @usableFromInline
    let width: Int

    @usableFromInline
    let height: Int

    @usableFromInline
    let samplesPerPixel: Int

    private func rayColor(_ r: Ray, maxDepth depth: Int, rand: inout WyRand) -> Vec3 {
        if _slowPath(depth <= 0) {
            return Vec3(0, 0, 0)
        }
        if let (hit, mat) = world.hit(r: r, t: 0.001...Double.infinity) {
            if let (attentuation, scattered) = mat.scatter(ray: r, hit: hit, rand: &rand) {
                return attentuation * rayColor(scattered, maxDepth: depth - 1, rand: &rand)
            }
            return Vec3(0, 0, 0)
        }
        let unitDirection = r.direction.normalized
        let t = 0.5 * (unitDirection.y + 1.0)
        return (1.0 - t) * Vec3(1, 1, 1) + t * Vec3(0.5, 0.7, 1.0)
    }

    func rayTrace(n: Int) -> Image {
        var image = Image(width: width, height: height)

        let q = DispatchQueue(label: "tracer", attributes: .concurrent)
        q.sync {
            let chunk = (width * height) / n

            DispatchQueue.concurrentPerform(iterations: n) { i in
                var rand = WyRand(seed: UInt64(i))

                let start = i * chunk
                for i in start..<(start + chunk) {
                    let y = height - i / width
                    let x = (i % width)

                    var color = Vec3(0, 0, 0)
                    for _ in 0..<samplesPerPixel {
                        let u = (Double(x) + rand.next()) / Double(width)
                        let v = (Double(y) + rand.next()) / Double(height)
                        let ray = camera.ray(at: u, v, rand: &rand)
                        color += rayColor(ray, maxDepth: maxDepth, rand: &rand)
                    }

                    image[i] = color.color(samplesPerPixel: samplesPerPixel)
                }
            }
        }

        return image
    }
}