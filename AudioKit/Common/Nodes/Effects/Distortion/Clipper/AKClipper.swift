// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
public class AKClipper: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "clip")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let limitDef = AKNodeParameterDef(
        identifier: "limit",
        name: "Threshold",
        address: AKClipperParameter.limit.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Threshold / limiting value.
    @Parameter public var limit: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKClipper.limitDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createClipperDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    public init(
        _ input: AKNode? = nil,
        limit: AUValue = 1.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.limit = limit
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
