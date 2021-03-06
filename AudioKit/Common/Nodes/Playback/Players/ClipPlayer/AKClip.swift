// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A protocol containing timing information for scheduling audio clips in a timeline.  All
/// properties are time values in seconds, relative to a zero based timeline.
@objc public protocol AKClip: AnyObject {

    /// The time in the timeline that the clip should begin playing.
    var time: Double { get }

    /// The offset into the clip's audio (where to start playing from within the clip).
    var offset: Double { get }

    /// The duration of playback.
    var duration: Double { get }
}

extension AKClip {

    /// Returns true is overlaps other clip.
    public func overlaps(_ otherClip: AKClip) -> Bool {
        return time < otherClip.endTime && endTime > otherClip.time
    }

    /// Default implementation is very basic.  Implementers of AKClip should implement this
    /// to ensure that enough information is available to ensure playback (eg. source file exists)
    public var isValid: Bool {
        return time >= 0 &&
            offset >= 0 &&
            duration > 0
    }

    /// Convenience to get clip end time.
    public var endTime: Double {
        return time + duration
    }
}

/// A file based AKClip
public protocol FileClip: AKClip {
    var audioFile: AVAudioFile { get }
}

/// A FileClip implementation, used by AKClipPlayer.
open class AKFileClip: NSObject, FileClip {

    /// The audio file that will be read.
    public var audioFile: AVAudioFile

    /// The time in the timeline that the clip should begin playing.
    public var time: Double

    /// The offset into the clip's audio (where to start playing from within the clip).
    public var offset: Double

    /// The duration of playback.
    public var duration: Double

    /// Create a new file clip.
    ///
    /// - Parameters:
    ///   - audioFile: The audio file that will be read.
    ///   - time: The time in the timeline that the clip should begin playing.
    ///   - offset: The offset into the clip's audio (where to start playing from within the clip).
    ///   - duration: The duration of playback.
    ///
    public init(audioFile: AVAudioFile,
                time: Double = 0,
                offset: Double = 0,
                duration: Double = 0) {

        self.audioFile = audioFile
        self.time = time
        self.offset = offset
        self.duration = duration == 0 ? audioFile.duration : duration
    }

    /// Init a file clip from a url with time and offset at zero, and duration set to file duration.
    public convenience init?(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let audioFile = try AVAudioFile(forReading: url)
            self.init(audioFile: audioFile)
            return
        } catch {
            AKLog(error.localizedDescription)
        }
        return nil
    }

}
