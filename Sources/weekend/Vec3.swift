import simd

@usableFromInline
typealias Vec3 = SIMD3<Double>

extension Vec3 {
    @usableFromInline
    func color(samplesPerPixel: Int) -> (UInt8, UInt8, UInt8) {
        let scale = 1.0 / Double(samplesPerPixel)
        let scaled = (self * scale).squareRoot()
        let clamped = scaled.clamped(lowerBound: SIMD3(0, 0, 0), upperBound: SIMD3(0.999, 0.999, 0.999))
        let norm = SIMD3<UInt8>(256 * clamped)
        return (norm.x, norm.y, norm.z)
    }

    @inline(__always)
    var length: Double {
        simd.length(self)
    }

    @inline(__always)
    var lengthSquared: Double {
        simd.length_squared(self)
    }

    @inline(__always)
    var normalized: Vec3 {
        //simd.normalize(self)
        self / self.length
    }

    @inline(__always)
    func reflected(by n: Vec3) -> Vec3 {
        simd.reflect(self, n: n)
        //self - 2 * dot(self, n) * n
    }

    func refracted(by n: Vec3, eta: Double) -> Vec3 {
        let cosΘ = dot(-self, n)
        let rParallel = eta * (self + cosΘ * n)
        let rPerp = -sqrt(1.0 - rParallel.lengthSquared) * n
        return rParallel + rPerp
    }

    @inline(__always)
    static func makeRandom(rand: inout WyRand) -> Vec3 {
        Vec3(rand.next(), rand.next(), rand.next())
    }

    @inline(__always)
    static func makeRandom(in range: ClosedRange<Double>, rand: inout WyRand) -> Vec3 {
        Vec3(rand.next(in: range), rand.next(in: range), rand.next(in: range))
    }

    @inline(__always)
    static func makeRandomInUnitSphere(rand: inout WyRand) -> Vec3 {
        var p: Vec3
        repeat {
            p = Self.makeRandom(in: -1...1, rand: &rand)
        } while p.lengthSquared >= 1
        return p
    }

    @inline(__always)
    static func makeRandomUnitVector(rand: inout WyRand) -> Vec3 {
        let a = rand.next(in: 0...2.0 * Double.pi)
        let z = rand.next(in: -1...1)
        let r = (1 - z * z).squareRoot()
        return Vec3(r * cos(a), r * sin(a), z)
    }

    static func makeRandomInUnitDisk(rand: inout WyRand) -> Vec3 {
        var p: Vec3
        repeat {
            p = Vec3(rand.next(in: -1...1), rand.next(in: -1...1), 0)
        } while p.lengthSquared >= 1
        return p
    }

    @inline(__always)
    func randomInHemisphere(rand: inout WyRand) -> Vec3 {
        let inUnitSphere = Self.makeRandomInUnitSphere(rand: &rand)
        return dot(inUnitSphere, self) > 0
                ? inUnitSphere  // In the same hemisphere as the normal
                : -inUnitSphere
    }
}
