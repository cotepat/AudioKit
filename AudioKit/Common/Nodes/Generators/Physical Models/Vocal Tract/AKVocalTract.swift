// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Based on the Pink Trombone algorithm by Neil Thapen, this implements a
/// physical model of the vocal tract glottal pulse wave. The tract model is
/// based on the classic Kelly-Lochbaum segmented cylindrical 1d waveguide
/// model, and the glottal pulse wave is a LF glottal pulse model.
///
public class AKVocalTract: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "vocw")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Glottal frequency.",
        address: AKVocalTractParameter.frequency.rawValue,
        range: 0.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    /// Glottal frequency.
    @Parameter public var frequency: AUValue

    public static let tonguePositionDef = AKNodeParameterDef(
        identifier: "tonguePosition",
        name: "Tongue position (0-1)",
        address: AKVocalTractParameter.tonguePosition.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Tongue position (0-1)
    @Parameter public var tonguePosition: AUValue

    public static let tongueDiameterDef = AKNodeParameterDef(
        identifier: "tongueDiameter",
        name: "Tongue diameter (0-1)",
        address: AKVocalTractParameter.tongueDiameter.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Tongue diameter (0-1)
    @Parameter public var tongueDiameter: AUValue

    public static let tensenessDef = AKNodeParameterDef(
        identifier: "tenseness",
        name: "Vocal tenseness. 0 = all breath. 1=fully saturated.",
        address: AKVocalTractParameter.tenseness.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Vocal tenseness. 0 = all breath. 1=fully saturated.
    @Parameter public var tenseness: AUValue

    public static let nasalityDef = AKNodeParameterDef(
        identifier: "nasality",
        name: "Sets the velum size. Larger values of this creates more nasally sounds.",
        address: AKVocalTractParameter.nasality.rawValue,
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Sets the velum size. Larger values of this creates more nasally sounds.
    @Parameter public var nasality: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKVocalTract.frequencyDef,
                    AKVocalTract.tonguePositionDef,
                    AKVocalTract.tongueDiameterDef,
                    AKVocalTract.tensenessDef,
                    AKVocalTract.nasalityDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createVocalTractDSP()
        }
    }

    // MARK: - Initialization

    /// Initialize this vocal tract node
    ///
    /// - Parameters:
    ///   - frequency: Glottal frequency.
    ///   - tonguePosition: Tongue position (0-1)
    ///   - tongueDiameter: Tongue diameter (0-1)
    ///   - tenseness: Vocal tenseness. 0 = all breath. 1=fully saturated.
    ///   - nasality: Sets the velum size. Larger values of this creates more nasally sounds.
    ///
    public init(
        frequency: AUValue = 160.0,
        tonguePosition: AUValue = 0.5,
        tongueDiameter: AUValue = 1.0,
        tenseness: AUValue = 0.6,
        nasality: AUValue = 0.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.frequency = frequency
        self.tonguePosition = tonguePosition
        self.tongueDiameter = tongueDiameter
        self.tenseness = tenseness
        self.nasality = nasality

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

    }
}
