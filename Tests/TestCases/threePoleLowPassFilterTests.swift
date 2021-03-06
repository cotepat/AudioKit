// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class ThreePoleLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: self.duration)
            return input.threePoleLowPassFilter(distortion: ramp, cutoffFrequency: ramp * 8_000, resonance: ramp * 0.9)
        }
        AKTestMD5("07d5c8083b2a4dfd4a2659994ddd76c7")
    }

}
