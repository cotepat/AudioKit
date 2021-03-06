// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Schedules multiple audio files to be played in a sequence.
public class AKClipPlayer: AKNode {

    private var timeAtStart: Double = 0

    /// The underlying player node
    public let playerNode = AVAudioPlayerNode()
    private var mixer = AVAudioMixerNode()
    private var isScheduled = false
    private var isNotScheduled: Bool { return !isScheduled }
    private var _clips = [FileClip]()

    /// Current time of the player in seconds.
    open var currentTime: Double {
        get { return position(at: nil) }
        set { setPosition(newValue) }
    }

    /// True is play, false if not.
    open var isPlaying: Bool {
        return playerNode.isPlaying
    }

    // swiftlint:disable force_cast

    /// Sets the clips sequence, throws if clips are invalid.
    ///
    /// In order for a clip sequence to be valid, they must be ordered by time, and
    /// time + duration must not exceed the following clip in sequence's time.  It's
    /// recommended to use A clip merger like AKFileClipSequence to build and modify
    /// the clips sequence.
    ///
    /// - Parameter clips: a validated array of Objects conforming to the FileClip protocol,
    /// use AKFileClips if you don't need custom behavior.
    /// - Throws: ClipMergeError if clips aren't valid.
    ///
    public func setClips(clips: [FileClip]) throws {
        try _clips = AKClipMerger.validateClips(clips) as! [FileClip]
        self.stop()
        isScheduled = false
    }
    // swiftlint:enable force_cast

    /// A valid clip sequence.
    open var clips: [FileClip] {
        get {
            return _clips
        }
        set {
            do {
                try setClips(clips: newValue)
            } catch {
                AKLog(error.localizedDescription)
            }
        }
    }

    // Offsets clips' time and duration when starting mid clip before scheduling
    private func scheduleClips(at offset: Double) {
        self.stop()

        for clip in clips {
            if clip.time < offset {
                if offset < clip.endTime {
                    let diff = offset - clip.time

                    scheduleFile(audioFile: clip.audioFile,
                                 time: 0,
                                 offset: clip.offset + diff,
                                 duration: clip.duration - diff,
                                 completion: nil)
                }

            } else {
                scheduleFile(audioFile: clip.audioFile,
                             time: clip.time - offset,
                             offset: clip.offset,
                             duration: clip.duration,
                             completion: nil)
            }
        }
        isScheduled = true
    }

    // swiftlint:disable force_cast

    /// Initializes a clipPlayer with clips.
    ///
    /// See setClips for discussion of clips validation
    ///
    /// - Parameter clips: a validated array of Objects conforming to the FileClip protocol,
    /// use AKFileClips if you don't need custom behavior.
    /// - Returns: A new player with clips if clips are valid, nil if not.
    ///
    public convenience init?(clips: [FileClip]) {
        do {
            let validatedClips = try AKClipMerger.validateClips(clips) as! [FileClip]
            self.init()
            _clips = validatedClips
        } catch {
            AKLog(error.localizedDescription)
            return nil
        }
    }
    // swiftlint:enable force_cast

    public init(clips: [FileClip]? = nil) {
        AKManager.engine.attach(playerNode)
        AKManager.engine.attach(mixer)
        AKManager.engine.connect(playerNode, to: mixer)
        super.init(avAudioNode: mixer, attach: false)

        if let clips = clips {
            self.clips = clips
        }
    }

    // Converts clip's parameters into sample times, and schedules the internal player to play them.
    private func scheduleFile(audioFile: AVAudioFile,
                              time: Double,
                              offset: Double,
                              duration: Double,
                              completion: (() -> Void)?) {
        let outputSampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let offsetFrame = AVAudioFramePosition(round(offset * audioFile.processingFormat.sampleRate))
        let frameCount = AVAudioFrameCount(round(duration * audioFile.processingFormat.sampleRate))

        let startTime = AVAudioTime(sampleTime: AVAudioFramePosition(round(time * outputSampleRate)),
                                    atRate: outputSampleRate)
        playerNode.scheduleSegment(audioFile,
                                   startingFrame: offsetFrame,
                                   frameCount: frameCount,
                                   at: startTime,
                                   completionHandler: completion)
    }

    /// Prepares previously scheduled file regions or buffers for playback.
    ///
    /// - Parameter frameCount: The number of sample frames of data to be prepared before returning.
    ///
    public func prepare(withFrameCount frameCount: AVAudioFrameCount) {
        if isNotScheduled {
            scheduleClips(at: currentTime)
        }
        playerNode.prepare(withFrameCount: frameCount)
    }

    /// Starts playback at next render cycle, AVAudioEngine must be running.
    public func play() {
        play(at: nil)
    }

    /// Starts playback at time
    ///
    /// - Parameter audioTime: A time in the audio render context.  If non-nil, the player's current
    /// current time will align with this time when playback starts.
    ///
    public func play(at audioTime: AVAudioTime?) {
        if isNotScheduled {
            scheduleClips(at: currentTime)
        }
        playerNode.play(at: audioTime)
        isScheduled = false
    }

    /// Stops playback.
    public func stop() {
        timeAtStart = position(at: nil)
        playerNode.stop()
        isScheduled = false
    }

    /// Volume 0.0 -> 1.0, default 1.0
    open var volume: Float {
        get { return playerNode.volume }
        set { playerNode.volume = newValue }
    }

    /// Left/Right balance -1.0 -> 1.0, default 0.0
    open var pan: Float {
        get { return playerNode.pan }
        set { playerNode.pan = newValue }
    }
}

extension AKClipPlayer: AKTiming {

    public var isStarted: Bool {
        return isPlaying
    }

    public func start(at audioTime: AVAudioTime? = nil) {
        play(at: audioTime)
    }

    public func setPosition(_ position: Double) {
        playerNode.stop()
        timeAtStart = position
    }

    public func position(at audioTime: AVAudioTime?) -> Double {
        guard let playerTime = playerNode.playerTime(forNodeTime: audioTime ?? AVAudioTime.now()) else {
            return timeAtStart
        }
        return timeAtStart + Double(playerTime.sampleTime) / playerTime.sampleRate
    }

    public func audioTime(at time: Double) -> AVAudioTime? {
        let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
        let sampleTime = (time - timeAtStart) * sampleRate
        let playerTime = AVAudioTime(sampleTime: AVAudioFramePosition(sampleTime), atRate: sampleRate)
        return playerNode.nodeTime(forPlayerTime: playerTime)
    }

    public func prepare() {
        prepare(withFrameCount: 8_192)
    }
}
