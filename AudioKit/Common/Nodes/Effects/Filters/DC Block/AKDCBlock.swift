// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1]) 
/// Based on work by Perry Cook.
///
public class AKDCBlock: AKNode, AKToggleable, AKComponent, AKInput {

    public static let ComponentDescription = AudioComponentDescription(effect: "dcbk")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {
        public override func createDSP() -> AKDSPRef {
            return createDCBlockDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///
    public init(
        _ input: AKNode? = nil
        ) {
        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)
        }
    }
}
