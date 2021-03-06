// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKOperation {

    /// Increment a signal by a default value of 1
    ///
    /// - Parameters:
    ///   - on: When to increment
    ///   - by: Increment amount (Default: 1)
    ///   - minimum: Increment amount (Default: 1)
    ///   - maximum: Increment amount (Default: 1)
    ///
    public func increment(on trigger: AKParameter,
                          by step: AKParameter = 1.0,
                          minimum: AKParameter = 0.0,
                          maximum: AKParameter = 1_000_000) -> AKOperation {
        return AKOperation(module: "incr", inputs: trigger, step, minimum, maximum, toMono())
    }
}
