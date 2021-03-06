// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AudioKit version of Apple's HighPassFilter Audio Unit
///
public class AKHighPassFilter: AKNode, AKToggleable, AUEffect, AKInput {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighPassFilter)

    private var mixer: AKMixer
    private var au: AUWrapper

    /// Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    public var cutoffFrequency: AUValue = 6_900 {
        didSet {
            cutoffFrequency = (10...22_050).clamp(cutoffFrequency)
            au[kHipassParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Resonance (dB) ranges from -20 to 40 (Default: 0)
    public var resonance: AUValue = 0 {
        didSet {
            resonance = (-20...40).clamp(resonance)
            au[kHipassParam_Resonance] = resonance
        }
    }

    /// Dry/Wet Mix (Default: 1)
    public var dryWetMix: AUValue = 1 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix
            effectGain?.volume = dryWetMix
        }
    }

    private var lastKnownMix: AUValue = 1
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?
    var inputMixer = AKMixer()

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    // MARK: - Initialization

    /// Initialize the high pass filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    ///   - resonance: Resonance (dB) ranges from -20 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 6_900,
        resonance: AUValue = 0) {
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        inputGain = AKMixer()
        inputGain?.volume = 0
        mixer = AKMixer(inputGain)

        effectGain = AKMixer()
        effectGain?.volume = 1

        input?.connect(to: inputMixer)

        if let inputGain = inputGain,
            let effectGain = effectGain {
            inputMixer.connect(to: [inputGain, effectGain])
        }

        let effect = _Self.effect
        internalEffect = effect

        au = AUWrapper(effect)
        super.init(avAudioNode: mixer.avAudioNode)

        AKManager.engine.attach(effect)

        if let node = effectGain?.avAudioNode {
            AKManager.engine.connect(node, to: effect)
        }
        AKManager.engine.connect(effect, to: mixer.avAudioNode)

        au[kHipassParam_CutoffFrequency] = cutoffFrequency
        au[kHipassParam_Resonance] = resonance
    }

    public var inputNode: AVAudioNode {
        return inputMixer.avAudioNode
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }

    /// Disconnect the node
    public override func detach() {
        stop()

        var nodes: [AVAudioNode] = [inputMixer.avAudioNode,
                                    mixer.avAudioNode,
                                    internalEffect]

        if let inputGain = inputGain {
            nodes.append(inputGain.avAudioNode)
        }

        if let effectGain = effectGain {
            nodes.append(effectGain.avAudioNode)
        }

        AKManager.detach(nodes: nodes)
    }
}
