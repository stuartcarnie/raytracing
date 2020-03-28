@usableFromInline
@frozen
struct Ray {
    let origin: Vec3
    let direction: Vec3

    func at(_ t: Double) -> Vec3 {
        origin + t * direction;
    }
}
