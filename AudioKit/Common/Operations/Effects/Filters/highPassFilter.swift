// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// A complement to the AKLowPassFilter.
    ///
    /// - parameter halfPowerPoint: Half-Power Point in Hertz. Half power is defined as peak power / square root of 2.
    ///                             (Default: 1000, Minimum: 12.0, Maximum: 20000.0)
    ///
    public func highPassFilter(
        halfPowerPoint: AKParameter = 1_000
        ) -> AKOperation {
        return AKOperation(module: "atone", inputs: toMono(), halfPowerPoint)
    }
}
