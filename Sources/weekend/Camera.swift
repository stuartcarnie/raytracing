import Darwin
import simd

@usableFromInline
@frozen
struct Camera {
    let origin: Vec3
    let lowerLeftCorner: Vec3
    let horizontal: Vec3
    let vertical: Vec3
    let u, v, w: Vec3
    let lensRadius: Double

    init(lookFrom: Vec3, lookAt: Vec3, verticalFOV fov: Double, aspect: Double, aperture: Double, focusDist: Double, up: Vec3 = Vec3(0, 1, 0)) {
        let Θ = fov.radians
        let halfHeight = tan(Θ / 2)
        let halfWidth = aspect * halfHeight

        w = (lookFrom - lookAt).normalized
        u = cross(up, w).normalized
        v = cross(w, u)

        origin = lookFrom
        lensRadius = aperture / 2
        // NOTE(sgc): Split expressions to reduce compile time from 5000ms to 130ms
        let t1 = halfWidth * focusDist * u
        let t2 = halfHeight * focusDist * v
        let t3 = focusDist * w
        lowerLeftCorner = origin - t1 - t2 - t3
        horizontal = 2 * t1
        vertical = 2 * t2
    }

    @usableFromInline
    @inline(__always)
    func ray(at s: Double, _ t: Double, rand: inout WyRand) -> Ray {
        let rd = lensRadius * Vec3.makeRandomInUnitDisk(rand: &rand)
        let offset = u * rd.x + v * rd.y
        let uu = s * horizontal
        let vv = t * vertical
        return Ray(origin: origin + offset, direction: lowerLeftCorner + uu + vv - origin - offset)
    }
}

extension BinaryFloatingPoint {
    var radians: Self {
        self * Self.pi / Self(180.0)
    }
}