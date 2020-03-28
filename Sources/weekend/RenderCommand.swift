import ArgumentParser
import Foundation

struct RenderCommand: ParsableCommand {
    @Option(default: 200)
    var width: Int

    @Option(default: 100)
    var height: Int

    @Option(default: 100)
    var samplesPerPixel: Int

    @Option(default: 50)
    var maxDepth: Int

    @Option(default: 16)
    var parallelize: Int

    @Option(name: [.customLong("out"), .customShort("o")], default: "out.png")
    var filename: String

    func makeRandomScene() -> World {
        var shapes: [Shape] = [
            .sphere(center: Vec3(0, -1000, 0), radius: 1000, mat: .lambertian(albedo: Vec3(0.5, 0.5, 0.5)))
        ]

        var rand = WyRand(seed: UInt64(Date().timeIntervalSince1970))

        for x in -11..<11 {
            for z in -11..<11 {
                let chooseMat: Double = rand.next()
                let center = Vec3(Double(x) + 0.9 * rand.next(), 0.2, Double(z) + 0.9 * rand.next())
                if (center - Vec3(4, 0.2, 0)).length > 0.9 {
                    switch chooseMat {
                    case ..<0.8:
                        let albedo: Vec3 = .makeRandom(rand: &rand) * .makeRandom(rand: &rand)
                        shapes.append(.sphere(center: center, radius: 0.2, mat: .lambertian(albedo: albedo)))

                    case 0.8..<0.95:
                        let albedo: Vec3 = .makeRandom(in: 0.5...1, rand: &rand)
                        let fuzz = rand.next(in: 0...0.5)
                        shapes.append(.sphere(center: center, radius: 0.2, mat: .metal(albedo: albedo, fuzz: fuzz)))

                    default:
                        shapes.append(.sphere(center: center, radius: 0.2, mat: .dielectric(refraction: 1.5)))
                    }
                }
            }
        }

        shapes.append(.sphere(center: Vec3(0, 1, 0), radius: 1.0, mat: .dielectric(refraction: 1.5)))
        shapes.append(.sphere(center: Vec3(-4, 1, 0), radius: 1.0, mat: .lambertian(albedo: Vec3(0.4, 0.2, 0.1))))
        shapes.append(.sphere(center: Vec3(4, 1, 0), radius: 1.0, mat: .metal(albedo: Vec3(0.7, 0.6, 0.5), fuzz: 0.0)))

        return World(shapes: shapes)
    }

    func run() throws {
        let world = makeRandomScene()

        let aspectRatio = Double(width) / Double(height)
        let lookFrom = Vec3(13, 2, 3)
        let lookAt = Vec3(0, 0, 0)
        let distToFocus = 10.0
        let aperture = 0.1

        let cam = Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                verticalFOV: 20,
                aspect: aspectRatio,
                aperture: aperture,
                focusDist: distToFocus)
        let scene = Scene(camera: cam, world: world, maxDepth: maxDepth, width: width, height: height, samplesPerPixel: samplesPerPixel)
        let image = scene.rayTrace(n: parallelize)
        image.writePNG(to: URL(fileURLWithPath: filename))
    }
}