// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighPassButterworthFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKHighPassButterworthFilter(input, cutoffFrequency: 400)
        AKTestMD5("eb971e324cde0e068749087d3e0177f5")
    }

    func testDefault() {
        output = AKHighPassButterworthFilter(input)
        AKTestMD5("a8dd0f6d878fbd6236bd951bc4cfedf6")
    }

}
