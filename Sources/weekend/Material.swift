import simd

@usableFromInline
@frozen
enum Material {
    case lambertian(albedo: Vec3)
    case metal(albedo: Vec3, fuzz: Double)
    case dielectric(refraction: Double)

    func scatter(ray: Ray, hit: RayHit, rand: inout WyRand) -> (Vec3, Ray)? {
        switch self {
        case .lambertian(let albedo):
            let scatterDirection = hit.normal + Vec3.makeRandomUnitVector(rand: &rand)
            return (albedo, Ray(origin: hit.p, direction: scatterDirection))

        case .metal(let albedo, let fuzz):
            let reflected = ray.direction.normalized.reflected(by: hit.normal)
                    + fuzz * Vec3.makeRandomInUnitSphere(rand: &rand)
            if dot(reflected, hit.normal) <= 0 {
                return .none
            }
            return (albedo, Ray(origin: hit.p, direction: reflected))

        case .dielectric(let refIdx):
            let eta = hit.frontFace ? (1.0 / refIdx) : refIdx
            let unitDirection = ray.direction.normalized
            let cosΘ = min(dot(-unitDirection, hit.normal), 1.0)
            let sinΘ = sqrt(1.0 - cosΘ * cosΘ)
            if eta * sinΘ > 1.0 {
                let reflected = unitDirection.reflected(by: hit.normal)
                return (Vec3(1, 1, 1), Ray(origin: hit.p, direction: reflected))
            }

            let reflectionProbability = Self.schlick(cos: cosΘ, refractionIndex: eta)
            if rand.next() < reflectionProbability {
                let reflected = unitDirection.reflected(by: hit.normal)
                return (Vec3(1, 1, 1), Ray(origin: hit.p, direction: reflected))
            }

            let refracted = unitDirection.refracted(by: hit.normal, eta: eta)
            return (Vec3(1, 1, 1), Ray(origin: hit.p, direction: refracted))
        }
    }

    private static func schlick(cos cosine: Double, refractionIndex r: Double) -> Double {
        let r0 = (1 - r) / (1 + r)
        let r² = r0 * r0
        return r² + (1 - r²) * pow(1 - cosine, 5)
    }
}
