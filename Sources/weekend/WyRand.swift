import simd

/// Wang Yi's PRNG from wyhash
/// See https://github.com/wangyi-fudan/wyhash/
@usableFromInline
@frozen
struct WyRand: RandomNumberGenerator {

    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    @usableFromInline
    mutating func next() -> UInt64 {
        state &+= 0xa0761d6478bd642f
        let mul = state.multipliedFullWidth(by: state ^ 0xe7037ed1a0b428db)
        return mul.high ^ mul.low
    }

    @usableFromInline
    mutating func next() -> Double {
        let v: UInt64 = next()
        return Double(v) / (Double(UInt64.max) + 1.0)
    }

    @usableFromInline
    mutating func next(in r: ClosedRange<Double>) -> Double {
        r.lowerBound + (r.upperBound - r.lowerBound) * next()
    }
}