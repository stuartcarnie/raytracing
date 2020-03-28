import simd

@usableFromInline
@frozen
enum Shape {
    case sphere(center: Vec3, radius: Double, mat: Material)

    @usableFromInline
    func hit(r: Ray, t: ClosedRange<Double>) -> (RayHit, Material)? {
        switch self {
        case .sphere(let center, let radius, let mat):
            if let rec = self.hitSphere(r: r, t: t, center: center, radius: radius) {
                return (rec, mat)
            }
        }
        return .none
    }

    private func hitSphere(r: Ray, t: ClosedRange<Double>, center: Vec3, radius: Double) -> RayHit? {
        let oc = r.origin - center;
        let a = r.direction.lengthSquared;
        let halfB = dot(oc, r.direction);
        let c = oc.lengthSquared - radius * radius;
        let discriminant = halfB * halfB - a * c;

        if discriminant > 0 {
            let root = sqrt(discriminant)
            do {
                let temp = (-halfB - root) / a
                if temp < t.upperBound && temp > t.lowerBound {
                    let p = r.at(temp)
                    let outwardNormal = (p - center) / radius
                    return RayHit(r: r, outwardNormal: outwardNormal, p: p, t: temp)
                }
            }

            do {
                let temp = (-halfB + root) / a
                if temp < t.upperBound && temp > t.lowerBound {
                    let p = r.at(temp)
                    let outwardNormal = (p - center) / radius
                    return RayHit(r: r, outwardNormal: outwardNormal, p: p, t: temp)
                }
            }
        }

        return .none
    }
}

@usableFromInline
@frozen
struct World {
    let shapes: [Shape]

    @usableFromInline
    func hit(r: Ray, t: ClosedRange<Double>) -> (RayHit, Material)? {
        var closestSoFar = t.upperBound
        var res: (RayHit, Material)?
        for shape in shapes {
            if let rec = shape.hit(r: r, t: t.lowerBound...closestSoFar) {
                closestSoFar = rec.0.t
                res = rec
            }
        }
        return res
    }
}