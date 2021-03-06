// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Reads from the table sequentially and repeatedly at given frequency.
/// Linear interpolation is applied for table look up from internal phase values.
///
public class AKOscillator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "oscl")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    fileprivate var waveform: AKTable?

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: AKOscillatorParameter.frequency.rawValue,
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Frequency in cycles per second
    @Parameter public var frequency: AUValue

    public static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: AKOscillatorParameter.amplitude.rawValue,
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Output Amplitude.
    @Parameter public var amplitude: AUValue

    public static let detuningOffsetDef = AKNodeParameterDef(
        identifier: "detuningOffset",
        name: "Frequency offset (Hz)",
        address: AKOscillatorParameter.detuningOffset.rawValue,
        range: -1_000.0 ... 1_000.0,
        unit: .hertz,
        flags: .default)

    /// Frequency offset in Hz.
    @Parameter public var detuningOffset: AUValue

    public static let detuningMultiplierDef = AKNodeParameterDef(
        identifier: "detuningMultiplier",
        name: "Frequency detuning multiplier",
        address: AKOscillatorParameter.detuningMultiplier.rawValue,
        range: 0.9 ... 1.11,
        unit: .generic,
        flags: .default)

    /// Frequency detuning multiplier
    @Parameter public var detuningMultiplier: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKOscillator.frequencyDef,
                    AKOscillator.amplitudeDef,
                    AKOscillator.detuningOffsetDef,
                    AKOscillator.detuningMultiplierDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createOscillatorDSP()
        }

    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform: The waveform of oscillation
    ///   - frequency: Frequency in cycles per second
    ///   - amplitude: Output Amplitude.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable = AKTable(.sine),
        frequency: AUValue = 440.0,
        amplitude: AUValue = 1.0,
        detuningOffset: AUValue = 0.0,
        detuningMultiplier: AUValue = 1.0
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setWavetable(waveform.content)
        }

    }
}
