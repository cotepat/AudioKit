// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Pulse-Width Modulating Oscillator Filter Synth 
///
public class AKPWMOscillatorFilterSynth: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKPWMOscillatorFilterSynthAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "pwmb")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    fileprivate var pulseWidthParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?
    fileprivate var pitchBendParameter: AUParameter?
    fileprivate var vibratoDepthParameter: AUParameter?
    fileprivate var vibratoRateParameter: AUParameter?
    fileprivate var filterCutoffFrequencyParameter: AUParameter?
    fileprivate var filterResonanceParameter: AUParameter?
    fileprivate var filterAttackDurationParameter: AUParameter?
    fileprivate var filterDecayDurationParameter: AUParameter?
    fileprivate var filterSustainLevelParameter: AUParameter?
    fileprivate var filterReleaseDurationParameter: AUParameter?
    fileprivate var filterEnvelopeStrengthParameter: AUParameter?
    fileprivate var filterLFODepthParameter: AUParameter?
    fileprivate var filterLFORateParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    public var rampDuration = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Duty cycle width (range 0-1).
    public var pulseWidth: AUValue = 0.5 {
        willSet {
            guard pulseWidth != newValue else { return }
            if internalAU?.isSetUp == true {
                pulseWidthParameter?.value = newValue
            } else {
                internalAU?.pulseWidth = newValue
            }
        }
    }

    /// Attack duration in seconds
    public var attackDuration: AUValue = 0.1 {
        willSet {
            guard attackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                attackDurationParameter?.value = newValue
            } else {
                internalAU?.attackDuration = newValue
            }
        }
    }

    /// Decay duration in seconds
    public var decayDuration: AUValue = 0.1 {
        willSet {
            guard decayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                decayDurationParameter?.value = newValue
            } else {
                internalAU?.decayDuration = newValue
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: AUValue = 1.0 {
        willSet {
            guard sustainLevel != newValue else { return }
            if internalAU?.isSetUp == true {
                sustainLevelParameter?.value = newValue
            } else {
                internalAU?.sustainLevel = newValue
            }
        }
    }

    /// Release duration in seconds
    public var releaseDuration: AUValue = 0.1 {
        willSet {
            guard releaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                releaseDurationParameter?.value = newValue
            } else {
                internalAU?.releaseDuration = newValue
            }
        }
    }

    /// Pitch Bend as number of semitones
    public var pitchBend: AUValue = 0 {
        willSet {
            guard pitchBend != newValue else { return }
            if internalAU?.isSetUp == true {
                pitchBendParameter?.value = newValue
            } else {
                internalAU?.pitchBend = newValue
            }
        }
    }

    /// Vibrato Depth in semitones
    public var vibratoDepth: AUValue = 0 {
        willSet {
            guard vibratoDepth != newValue else { return }
            if internalAU?.isSetUp == true {
                vibratoDepthParameter?.value = newValue
            } else {
                internalAU?.vibratoDepth = newValue
            }
        }
    }

    /// Vibrato Rate in Hz
    public var vibratoRate: AUValue = 0 {
        willSet {
            guard vibratoRate != newValue else { return }
            if internalAU?.isSetUp == true {
                vibratoRateParameter?.value = newValue
            } else {
                internalAU?.vibratoRate = newValue
            }
        }
    }
    /// Filter Cutoff Frequency in Hz
    public var filterCutoffFrequency: AUValue = 22_050.0 {
        willSet {
            guard filterCutoffFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                filterCutoffFrequencyParameter?.value = newValue
            } else {
                internalAU?.filterCutoffFrequency = newValue
            }
        }
    }

    /// Filter Resonance
    public var filterResonance: AUValue = 22_050.0 {
        willSet {
            guard filterResonance != newValue else { return }
            if internalAU?.isSetUp == true {
                filterResonanceParameter?.value = newValue
            } else {
                internalAU?.filterResonance = newValue
            }
        }
    }

    /// Filter Attack Duration in seconds
    public var filterAttackDuration: AUValue = 0.1 {
        willSet {
            guard filterAttackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterAttackDurationParameter?.value = newValue
            } else {
                internalAU?.filterAttackDuration = newValue
            }
        }
    }

    /// Filter Decay Duration in seconds
    public var filterDecayDuration: AUValue = 0.1 {
        willSet {
            guard filterDecayDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterDecayDurationParameter?.value = newValue
            } else {
                internalAU?.filterDecayDuration = newValue
            }
        }
    }
    /// Filter Sustain Level
    public var filterSustainLevel: AUValue = 1.0 {
        willSet {
            guard filterSustainLevel != newValue else { return }
            if internalAU?.isSetUp == true {
                filterSustainLevelParameter?.value = newValue
            } else {
                internalAU?.filterSustainLevel = newValue
            }
        }
    }
    /// Filter Release Duration in seconds
    public var filterReleaseDuration: AUValue = 0.1 {
        willSet {
            guard filterReleaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                filterReleaseDurationParameter?.value = newValue
            } else {
                internalAU?.filterReleaseDuration = newValue
            }
        }
    }
    ///Filter Envelope Strength
    public var filterEnvelopeStrength: AUValue = 0.1 {
        willSet {
            guard filterEnvelopeStrength != newValue else { return }
            if internalAU?.isSetUp == true {
                filterEnvelopeStrengthParameter?.value = newValue
            } else {
                internalAU?.filterEnvelopeStrength = newValue
            }
        }
    }
    ///Filter LFO Depth
    public var filterLFODepth: AUValue = 0.1 {
        willSet {
            guard filterLFODepth != newValue else { return }
            if internalAU?.isSetUp == true {
                filterLFODepthParameter?.value = newValue
            } else {
                internalAU?.filterLFODepth = newValue
            }
        }
    }
    ///Filter LFO Rate
    public var filterLFORate: AUValue = 0.1 {
        willSet {
            guard filterLFORate != newValue else { return }
            if internalAU?.isSetUp == true {
                filterLFORateParameter?.value = newValue
            } else {
                internalAU?.filterLFORate = newValue
            }
        }
    }
    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - attackDuration: Attack duration in seconds
    ///   - decayDuration: Decay duration in seconds
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release duration in seconds
    ///   - pitchBend: Change of pitch in semitones
    ///   - vibratoDepth: Vibrato size in semitones
    ///   - vibratoRate: Frequency of vibrato in Hz
    ///   - filterCutoffFrequency: Frequency of filter cutoff in Hz
    ///   - filterResonance: Filter resonance
    ///   - filterAttackDuration: Filter attack duration in seconds
    ///   - filterDecayDuration: Filter decay duration in seconds
    ///   - filterSustainLevel: Filter sustain level
    ///   - filterReleaseDuration: Filter release duration in seconds
    ///   - filterEnvelopeStrength: Strength of the filter envelope on filter
    ///   - filterLFODepth: Depth of LFO on filter
    ///   - filterLFORate: Speed of filter LFO
    ///
    public init(
        pulseWidth: AUValue = 0.5,
        attackDuration: AUValue = 0.1,
        decayDuration: AUValue = 0.1,
        sustainLevel: AUValue = 1.0,
        releaseDuration: AUValue = 0.1,
        pitchBend: AUValue = 0,
        vibratoDepth: AUValue = 0,
        vibratoRate: AUValue = 0,
        filterCutoffFrequency: AUValue = 22_050.0,
        filterResonance: AUValue = 0.0,
        filterAttackDuration: AUValue = 0.1,
        filterDecayDuration: AUValue = 0.1,
        filterSustainLevel: AUValue = 1.0,
        filterReleaseDuration: AUValue = 1.0,
        filterEnvelopeStrength: AUValue = 0.0,
        filterLFODepth: AUValue = 0.0,
        filterLFORate: AUValue = 0.0) {

        self.pulseWidth = pulseWidth
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.pitchBend = pitchBend
        self.vibratoDepth = vibratoDepth
        self.vibratoRate = vibratoRate
        self.filterCutoffFrequency = filterCutoffFrequency
        self.filterResonance = filterResonance
        self.filterAttackDuration = filterAttackDuration
        self.filterDecayDuration = filterDecayDuration
        self.filterSustainLevel = filterSustainLevel
        self.filterReleaseDuration = filterReleaseDuration
        self.filterEnvelopeStrength = filterEnvelopeStrength
        self.filterLFODepth = filterLFODepth
        self.filterLFORate = filterLFORate

        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        pulseWidthParameter = tree["pulseWidth"]
        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        pitchBendParameter = tree["pitchBend"]
        vibratoDepthParameter = tree["vibratoDepth"]
        vibratoRateParameter = tree["vibratoRate"]
        filterCutoffFrequencyParameter = tree["filterCutoffFrequency"]
        filterResonanceParameter = tree["filterResonance"]
        filterAttackDurationParameter = tree["filterAttackDuration"]
        filterDecayDurationParameter = tree["filterDecayDuration"]
        filterSustainLevelParameter = tree["filterSustainLevel"]
        filterReleaseDurationParameter = tree["filterReleaseDuration"]
        filterEnvelopeStrengthParameter = tree["filterEnvelopeStrength"]
        filterLFODepthParameter = tree["filterLFODepth"]
        filterLFORateParameter = tree["filterLFORate"]

        internalAU?.pulseWidth = pulseWidth
        internalAU?.attackDuration = attackDuration
        internalAU?.decayDuration = decayDuration
        internalAU?.sustainLevel = sustainLevel
        internalAU?.releaseDuration = releaseDuration
        internalAU?.pitchBend = pitchBend
        internalAU?.vibratoDepth = vibratoDepth
        internalAU?.vibratoRate = vibratoRate
        internalAU?.filterCutoffFrequency = filterCutoffFrequency
        internalAU?.filterResonance = filterResonance
        internalAU?.filterAttackDuration = filterAttackDuration
        internalAU?.filterDecayDuration = filterDecayDuration
        internalAU?.filterSustainLevel = filterSustainLevel
        internalAU?.filterReleaseDuration = filterReleaseDuration
        internalAU?.filterEnvelopeStrength = filterEnvelopeStrength
        internalAU?.filterLFODepth = filterLFODepth
        internalAU?.filterLFORate = filterLFORate
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    public override func play(noteNumber: MIDINoteNumber,
                              velocity: MIDIVelocity,
                              frequency: AUValue,
                              channel: MIDIChannel = 0) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: frequency)
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
