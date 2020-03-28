import simd

@usableFromInline
@frozen
struct RayHit {
    @usableFromInline
    let p: Vec3

    @usableFromInline
    let normal: Vec3

    @usableFromInline
    let t: Double

    @usableFromInline
    let frontFace: Bool

    @usableFromInline
    init(r: Ray, outwardNormal: Vec3, p: Vec3, t: Double) {
        self.p = p
        self.t = t
        self.frontFace = dot(r.direction, outwardNormal) < 0
        self.normal = self.frontFace ? outwardNormal : -outwardNormal
    }
}